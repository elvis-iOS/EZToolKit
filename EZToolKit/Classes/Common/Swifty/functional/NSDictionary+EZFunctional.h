//
//  NSDictionary+EZFunctional.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<KeyType, ValueType> (EZFunctional)

typedef id _Nullable (^EZDictionaryMapBlock)(KeyType key, ValueType value);
typedef id _Nullable (^EZDictionaryValueMapBlock)(ValueType value);
typedef BOOL (^EZDictioanryPredicateBlock)(KeyType key, ValueType value);
typedef void (^EZDictionaryEnumeratorBlock)(KeyType key, ValueType value);
typedef id __nullable (^EZDictionaryReducerBlock)(id __nullable accumulator, KeyType key, ValueType value);



- (NSArray *)ez_map:(NS_NOESCAPE EZDictionaryMapBlock)mapper NS_SWIFT_UNAVAILABLE("");
- (NSArray *)ez_flatMap:(NS_NOESCAPE EZDictionaryMapBlock)mapper NS_SWIFT_UNAVAILABLE("");
- (NSDictionary<KeyType, id> *)ez_mapValues:(NS_NOESCAPE EZDictionaryValueMapBlock)mapper NS_SWIFT_UNAVAILABLE("");
- (instancetype)ez_filter:(NS_NOESCAPE EZDictioanryPredicateBlock)predicate NS_SWIFT_UNAVAILABLE("");
- (nullable KeyType)ez_first:(NS_NOESCAPE EZDictioanryPredicateBlock)predicate NS_SWIFT_UNAVAILABLE("");
- (void)ez_forEach:(NS_NOESCAPE EZDictionaryEnumeratorBlock)block NS_SWIFT_UNAVAILABLE("");
- (nullable id)ez_reduce:(nullable id)initialValue
                  combine:(NS_NOESCAPE EZDictionaryReducerBlock)reducer NS_SWIFT_UNAVAILABLE("");
- (NSArray<NSArray *> *)ez_zip:(id)container NS_SWIFT_UNAVAILABLE("");

@end

NS_ASSUME_NONNULL_END
