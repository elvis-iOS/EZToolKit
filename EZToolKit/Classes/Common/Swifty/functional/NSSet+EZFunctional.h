//
//  NSSet+EZFunctional.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSet<T> (EZFunctional)

typedef id _Nullable (^EZArrayMapBlock)(T);
typedef BOOL (^EZPredicateBlock)(T);
typedef void (^EZArrayEnumeratorBlock)(T value);
typedef id __nullable (^EZArrayReducerBlock)(id __nullable accumulator, T value);


- (NSArray *)ez_map:(NS_NOESCAPE EZArrayMapBlock)mapper NS_SWIFT_UNAVAILABLE("");
- (NSArray *)ez_flatMap:(NS_NOESCAPE EZArrayMapBlock)mapper NS_SWIFT_UNAVAILABLE("");
- (instancetype)ez_filter:(NS_NOESCAPE EZPredicateBlock)predicate NS_SWIFT_UNAVAILABLE("");
- (nullable T)ez_first:(NS_NOESCAPE EZPredicateBlock)predicate NS_SWIFT_UNAVAILABLE("");
- (void)ez_forEach:(NS_NOESCAPE EZArrayEnumeratorBlock)block NS_SWIFT_UNAVAILABLE("");
- (nullable id)ez_reduce:(nullable id)initialValue
                  combine:(NS_NOESCAPE EZArrayReducerBlock)reducer NS_SWIFT_UNAVAILABLE("");
- (NSArray<NSArray *> *)ez_zip:(id)container NS_SWIFT_UNAVAILABLE("");

@end

NS_ASSUME_NONNULL_END
