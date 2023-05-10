//
//  EZQueue.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZQueue<T> : NSObject

- (void)inqueue:(T)obj;
- (void)inqueueValues:(NSArray<T> *)values;
- (T _Nullable)dequeue;
- (NSArray<T> * _Nullable)dequeueFirst:(int)count;
- (void)clear;
- (BOOL)isEmpty;

@end

NS_ASSUME_NONNULL_END
