//
//  main.m
//  YXObserverAndKVO
//
//  Created by LYX on 2018/11/6.
//  Copyright © 2018 LYX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        if (@available(iOS 10.0, *)) {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        } else {
            // Fallback on earlier versions
        }
    }
}
