//
//  AppDelegate.h
//  YXObserverAndKVO
//
//  Created by LYX on 2018/11/6.
//  Copyright © 2018 LYX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

API_AVAILABLE(ios(10.0))
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

