//
//  NSNotificationCenter+lyxObserver.h
//  MvBox
//
//  Created by LYX on 2018/11/1.
//  Copyright © 2018 mvbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RACDisposable.h"

#define lyxAddObserver(aObserver, aName, anObject) [NSNotificationCenter defaultCenter]lyx_addObserver:aObserver name:aName object:anObject

#define lyxPostNotification(aName, anObject) [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject]

#define lyxRemoveAllObservers(aObserver) [[NSNotificationCenter defaultCenter]lyx_removeAllObservers:aObserver]

#define lyxRemoveObserver(aObserver, aName) [[NSNotificationCenter defaultCenter]lyx_removeObserver:aObserver name:aName]


NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (LYXObserver)

- (RACDisposable *)lyx_addObserver:(id)observer name:(nullable NSNotificationName)name object:(nullable id)object block:(void (^)(NSNotification *notification))block;

- (RACDisposable *)lyx_addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject;
- (RACDisposable *)lyx_addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject block:(void (^)(NSNotification *notification))block;

- (void)lyx_removeObserver:(id)observe name:(NSString *)name;
- (void)lyx_removeAllObservers:(id)observe;
@end

NS_ASSUME_NONNULL_END
