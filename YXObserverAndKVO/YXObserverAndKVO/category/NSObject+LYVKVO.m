//
//  NSObject+lyxKVO.m
//  MvBox
//
//  Created by LYX on 2018/11/1.
//  Copyright © 2018 mvbox. All rights reserved.
//

#import "NSObject+LYXKVO.h"
#import "NSObject+RACKVOWrapper.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation NSObject (LYXKVO)
static void *const lyxKVOKey = "lyxKVOKey";
static void *const lyxKVOSemaphoreKey = "lyxKVOSemaphoreKey";

- (RACDisposable *)lyx_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context{
    
    @weakify(observer);
    RACDisposable *dis = [self rac_observeKeyPath:keyPath options:options observer:observer block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        @strongify(observer);
        
        SEL aSelector = NSSelectorFromString(@"observeValueForKeyPath:ofObject:change:context:");
        IMP imp = [observer methodForSelector:aSelector];
        void (*func)(id, SEL, NSString *, id, NSDictionary *, void *) = (void *)imp;
        func(observer, aSelector, keyPath, self, change, context);
    }];
    [self _savelyxKVOKeyPath:keyPath dis:dis];

    return dis;
}

- (RACDisposable *)lyx_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context block:(void (^)(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent))block{
    
    return [self lyx_observeKeyPath:keyPath options:options observer:observer block:block];
}

- (RACDisposable *)lyx_observeKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options observer:(NSObject *)observer block:(void (^)(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent))block{

    RACDisposable *dis =[self rac_observeKeyPath:keyPath options:options observer:observer block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        block(value, change, causedByDealloc, affectedOnlyLastComponent);
    }];
    [self _savelyxKVOKeyPath:keyPath dis:dis];

    return dis;
}

- (RACDisposable *)lyx_observeKeyPath:(NSString *)keyPath observer:(NSObject *)observer block:(void (^)(id x))nextBlock{

    RACDisposable *dis = [[self rac_valuesForKeyPath:keyPath observer:observer]subscribeNext:^(id x) {
        nextBlock(x);
    }];
    [self _savelyxKVOKeyPath:keyPath dis:dis];

    return  dis;
}

- (RACDisposable *)lyx_observe:(NSObject *)observer block:(void (^)(id x))nextBlock{
    return [self lyx_observeKeyPath:@keypath(observer, self) observer:observer block:^(id  _Nonnull x) {
        nextBlock(x);
    }];
}



- (void)lyx_removeObserverForKeyPath:(NSString *)keyPath{
    if (!keyPath.length) return;

    dispatch_semaphore_t kvoSemaphore = [self _getlyxKVOSemaphoreWithKey:lyxKVOSemaphoreKey];
    dispatch_semaphore_wait(kvoSemaphore, DISPATCH_TIME_FOREVER);
    NSMutableDictionary *dict = objc_getAssociatedObject(self, lyxKVOKey);
    if (dict){
        RACDisposable *target = dict[keyPath];
        if (target){
            [target dispose];
            [dict removeObjectForKey:keyPath];
        }
    }

    dispatch_semaphore_signal(kvoSemaphore);
}

- (void)lyx_removeAllObservers{

    dispatch_semaphore_t kvoSemaphore = [self _getlyxKVOSemaphoreWithKey:lyxKVOSemaphoreKey];
    dispatch_semaphore_wait(kvoSemaphore, DISPATCH_TIME_FOREVER);
    NSMutableDictionary *dict = objc_getAssociatedObject(self, lyxKVOKey);
    if (dict){
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, RACDisposable *target, BOOL *stop) {
            [target dispose];
        }];
        [dict removeAllObjects];
    }

    dispatch_semaphore_signal(kvoSemaphore);
}

- (void)_savelyxKVOKeyPath:(NSString *)keyPath dis:(RACDisposable *)dis{
    dispatch_semaphore_t kvoSemaphore = [self _getlyxKVOSemaphoreWithKey:lyxKVOSemaphoreKey];
    dispatch_semaphore_wait(kvoSemaphore, DISPATCH_TIME_FOREVER);
    NSMutableDictionary *dict = objc_getAssociatedObject(self, lyxKVOKey);
    if (!dict) {
        dict = [NSMutableDictionary new];
        objc_setAssociatedObject(self, lyxKVOKey, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [dict setObject:dis forKey:keyPath];
    dispatch_semaphore_signal(kvoSemaphore);
}

- (dispatch_semaphore_t)_getlyxKVOSemaphoreWithKey:(void *)key{
    dispatch_semaphore_t semaphore = objc_getAssociatedObject(self, key);
    if (!semaphore) {
        semaphore = dispatch_semaphore_create(1);
        objc_setAssociatedObject(self, key, semaphore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return semaphore;
}
@end
