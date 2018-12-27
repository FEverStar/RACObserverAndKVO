//
//  NSNotificationCenter+lyxObserver.m
//  MvBox
//
//  Created by LYX on 2018/11/1.
//  Copyright © 2018 mvbox. All rights reserved.
//

#import "NSNotificationCenter+LYXObserver.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <objc/runtime.h>
#import <objc/message.h>

static void *const lyxObserverKey = "lyxObserverKey";
static void *const lyxObserverSemaphoreKey = "lyxObserverSemaphoreKey";

@implementation NSNotificationCenter (LYXObserver)

- (RACDisposable *)lyx_addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject block:(void (^)(NSNotification *notification))block{
    
    return [self lyx_addObserver:observer name:aName object:anObject block:block];
}


- (RACDisposable *)lyx_addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject{
    
    @weakify(observer);
    RACDisposable *dis =[[[self rac_addObserverForName:aName object:anObject] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification *not) {
        @strongify(observer);
        
        IMP imp = [observer methodForSelector:aSelector];
        void (*func)(id, SEL, NSNotification *) = (void *)imp;
        func(observer, aSelector, not);
    }];
    [self _savelyxName:aName dis:dis observer:observer];

    return dis;
}
- (RACDisposable *)lyx_addObserver:(id)observer name:(nullable NSNotificationName)name object:(nullable id)object block:(void (^)(NSNotification *notification))block{
    
     RACDisposable *dis = [[[self rac_addObserverForName:name object:object] takeUntil:[observer rac_willDeallocSignal]] subscribeNext:^(NSNotification *not) {
        
        block(not);
    }];
    [self _savelyxName:name dis:dis observer:observer];

    return dis;
    
}

- (void)lyx_removeObserver:(id)observe name:(NSString *)name{
    if (!name.length) return;
    
    dispatch_semaphore_t kvoSemaphore = [self _getlyxSemaphoreWithKey:lyxObserverSemaphoreKey];
    dispatch_semaphore_wait(kvoSemaphore, DISPATCH_TIME_FOREVER);
    NSMutableDictionary *dict = objc_getAssociatedObject(observe, lyxObserverKey);
    if (dict) {
        RACDisposable *target = dict[name];
        if (target){
            [target dispose];
            [dict removeObjectForKey:name];
        }
    }
    dispatch_semaphore_signal(kvoSemaphore);
}

- (void)lyx_removeAllObservers:(id)observe{

    dispatch_semaphore_t kvoSemaphore = [self _getlyxSemaphoreWithKey:lyxObserverSemaphoreKey];
    dispatch_semaphore_wait(kvoSemaphore, DISPATCH_TIME_FOREVER);
    NSMutableDictionary *dict = objc_getAssociatedObject(observe, lyxObserverKey);
    if (dict) {
        [dict enumerateKeysAndObjectsUsingBlock:^(id key, RACDisposable *target, BOOL *stop) {
            [target dispose];
        }];
        [dict removeAllObjects];
    }
    dispatch_semaphore_signal(kvoSemaphore);
}

- (void)_savelyxName:(NSString *)name dis:(RACDisposable *)dis observer:(id)observe{
    dispatch_semaphore_t kvoSemaphore = [self _getlyxSemaphoreWithKey:lyxObserverSemaphoreKey];
    dispatch_semaphore_wait(kvoSemaphore, DISPATCH_TIME_FOREVER);
    NSMutableDictionary *dict = objc_getAssociatedObject(observe, lyxObserverKey);
    if (!dict) {
        dict = [NSMutableDictionary new];
        objc_setAssociatedObject(observe, lyxObserverKey, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [dict setObject:dis forKey:name];
    dispatch_semaphore_signal(kvoSemaphore);
}

- (dispatch_semaphore_t)_getlyxSemaphoreWithKey:(void *)key{
    dispatch_semaphore_t semaphore = objc_getAssociatedObject(self, key);
    if (!semaphore) {
        semaphore = dispatch_semaphore_create(1);
        objc_setAssociatedObject(self, key, semaphore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return semaphore;
}
@end
