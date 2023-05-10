//
//  NSObject+Nonnull.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/3/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Nonnull)

///
/// 指定不检测是否非空的属性
///
+ (NSArray *)ez_exceptionsKeys;

///
/// 指定需要嵌套调用ez_isNonnull的属性
///
+ (NSArray *)ez_subKeys;

- (BOOL)ez_isNonnull;

@end

NS_ASSUME_NONNULL_END
