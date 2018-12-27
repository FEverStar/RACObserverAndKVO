//
//  NSObject+lyxKVO.h
//  MvBox
//
//  Created by LYX on 2018/11/1.
//  Copyright © 2018 mvbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RACDisposable.h"
#import <objc/runtime.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LYXKVO)

- (RACDisposable *)lyx_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;

- (RACDisposable *)lyx_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context block:(void (^)(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent))block;


- (RACDisposable *)lyx_observeKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options observer:(NSObject *)observer block:(void (^)(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent))block;


- (RACDisposable *)lyx_observeKeyPath:(NSString *)keyPath observer:(NSObject *)observer block:(void (^)(id x))nextBlock;

- (RACDisposable *)lyx_observe:(NSObject *)observer block:(void (^)(id x))nextBlock;


- (void)lyx_removeObserverForKeyPath:(NSString *)keyPath;
- (void)lyx_removeAllObservers;

@end

NS_ASSUME_NONNULL_END
