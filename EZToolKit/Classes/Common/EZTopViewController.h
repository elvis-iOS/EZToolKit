//
//  EZTopViewController.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZTopViewController : NSObject

///@retval keyWindow最顶层ViewController
+ (UIViewController *)getTop;

///@retval keyWindow根ViewController
+ (UIViewController *)getRootVC;

///判断当前ViewController是否在最顶层
+ (BOOL)isTop:(UIViewController *)viewController;

///遍历顶层视图控制器的中的视图，直到找到指定视图类为止
///@param viewClassName 指定的view的类名
+ (UIView *)findViewInTopVC:(NSString *)viewClassName;

///在指定View中遍历subview, 直到找到指定视图类为止
+ (UIView *)findViewOfClass:(Class)viewClass
                     inView:(UIView *)contentView;

/// 在指定View中遍历subview, 并忽略未显示的subview, 直到找到指定视图类为止
+ (NSArray<UIView *> *)findViewsOfClass:(Class)viewClass
                                 inView:(UIView *)contentView
                      ignoreHiddenViews:(BOOL)shouldIgnoreHidden;
@end

NS_ASSUME_NONNULL_END
