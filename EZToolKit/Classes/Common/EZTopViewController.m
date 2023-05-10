//
//  TopViewController.m
//  do
//
//  Created by Elvis on 2020/7/2.
//  Copyright © 2020 cj. All rights reserved.
//

#import "EZTopViewController.h"

@implementation EZTopViewController

#pragma mark - Public
+ (UIViewController *)getTop {
    UIViewController *rootViewController = [EZTopViewController _getViewControllerWindow].rootViewController;
    UIViewController *currentVC = [EZTopViewController _getCurrentVCFrom:rootViewController];
    return currentVC;
}

+ (UIViewController *)getRootVC {
    return [EZTopViewController _getViewControllerWindow].rootViewController;
}


+ (BOOL)isTop:(UIViewController *)viewController {
    if (!viewController)
        return false;
    
    if ([viewController isKindOfClass:[UIViewController class]] == false)
        return false;
    
    UIViewController *topVC = [EZTopViewController getTop];
    return viewController == topVC;
}

+ (UIView *)findViewInTopVC:(NSString *)viewClassName {
    UIView *contentView = [[EZTopViewController getTop] view];
    Class viewClass = NSClassFromString(viewClassName);
    if (!contentView || viewClass == NULL)
        return nil;
    
    return [EZTopViewController findViewOfClass:viewClass inView:contentView];
}

+ (UIView *)findViewOfClass:(Class)viewClass inView:(UIView *)contentView {
    if ([contentView isKindOfClass:viewClass])
        return contentView;

    UIView *retVal;
    for (UIView *v in [contentView subviews]) {
        retVal = [EZTopViewController findViewOfClass:viewClass inView:v];
        if (retVal) break;
    }
    return retVal;
}

+ (NSArray<UIView *> *)findViewsOfClass:(Class)viewClass
                                 inView:(UIView *)contentView
                      ignoreHiddenViews:(BOOL)shouldIgnoreHidden {
    NSMutableArray *retVal = @[].mutableCopy;
    if ([contentView subviews].count == 0)
        return retVal;
    
    for (UIView *v in [contentView subviews]) {
        if ([v isKindOfClass:viewClass]) {
            if (shouldIgnoreHidden) {
                if (CGRectIsEmpty(v.frame) || CGRectIsNull(v.frame) || v.isHidden == YES || v.alpha == 0) {
                    continue;
                }
            }
            [retVal addObject:v];
        }
        [retVal addObjectsFromArray:[self findViewsOfClass:viewClass inView:v ignoreHiddenViews:shouldIgnoreHidden]];
    }
    
    return retVal;
}

#pragma mark - Private
/**
 获取rootViewController所在的window
 */
+ (UIWindow *)_getViewControllerWindow{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [UIApplication sharedApplication].windows;
        for (UIWindow *target in windows) {
            if (target.windowLevel == UIWindowLevelNormal) {
                window = target;
                break;
            }
        }
    }
    return window;
}
/**
 递归查找最上层视图控制器
 */
+ (UIViewController *)_getCurrentVCFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        while ([rootVC presentedViewController]) {
            rootVC = [rootVC presentedViewController];
        }
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]])
        currentVC = [self _getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    
    else if ([rootVC isKindOfClass:[UINavigationController class]])
        currentVC = [self _getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    
    else
        currentVC = rootVC;
    
    return currentVC;
}


@end
