//
//  EZStack.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZStack<T> : NSObject

- (void)push:(T)value;
- (void)pushValues:(NSArray<T> *)values;
- (T _Nullable)pop;
- (NSArray<T> * _Nullable)popFirst:(int)count;
- (void)clear;
- (BOOL)isEmpty;

@end

NS_ASSUME_NONNULL_END
