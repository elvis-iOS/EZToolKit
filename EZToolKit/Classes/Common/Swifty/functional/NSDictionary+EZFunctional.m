//
//  NSDictionary+EZFunctional.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/26.
//

#import "NSDictionary+EZFunctional.h"

FOUNDATION_EXTERN NSArray<NSArray *> *ez_zip(id container1, id container2);

static NSDictionary *ez_dictionaryFilter(NSDictionary *dictionary, BOOL (^predicate)(id, id)) {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for (id key in dictionary) {
        id value = dictionary[key];
        if (predicate(key, value)) {
            result[key] = value;
        }
    }
    return result;
}

static id __nullable ez_dictionaryFirst(NSDictionary *dictionary, BOOL (^predicate)(id, id)) {
    for (id key in dictionary) {
        if (predicate(key, dictionary[key])) {
            return key;
        }
    }
    return nil;
}

static NSArray *ez_dictionaryFlatMap(NSDictionary *dictionary, id __nullable (^mapper)(id, id)) {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (id key in dictionary) {
        id mapped = mapper(key, dictionary[key]);
        if ([mapped isKindOfClass:[NSDictionary class]]) {
            [result addObjectsFromArray:[mapped allValues]];
        } else if (mapped) {
            [result addObject:mapped];
        }
    }
    return result;
}

static void ez_dictionaryForEach(NSDictionary *dictionary, void (^block)(id, id)) {
    for (id key in dictionary) {
        block(key, dictionary[key]);
    }
}

static NSArray *ez_dictionaryMap(NSDictionary *dictionary, id __nullable (^mapper)(id, id)) {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (id key in dictionary) {
        id mapped = mapper(key, dictionary[key]);
        [result addObject:mapped ?: [NSNull null]];
    }
    return result;
}

static NSDictionary *ez_dictionaryMapValues(NSDictionary *dictionary, id __nullable (^mapper)(id)) {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for (id key in dictionary) {
        id mapped = mapper(dictionary[key]);
        result[key] = mapped ?: [NSNull null];
    }
    return result;
}

static id __nullable ez_dictionaryReduce(NSDictionary *dictionary, id __nullable initialValue,
                                         id __nullable (^reducer)(id __nullable, id, id)) {
    id result = initialValue;
    for (id key in dictionary) {
        result = reducer(result, key, dictionary[key]);
    }
    return result;
}

@implementation NSDictionary (EZFunctional)

- (instancetype)ez_filter:(NS_NOESCAPE BOOL (^)(id, id))predicate {
    NSParameterAssert(predicate);
    
    return ez_dictionaryFilter(self, predicate);
}

- (nullable id)ez_first:(NS_NOESCAPE BOOL (^)(id, id))predicate {
    NSParameterAssert(predicate);
    
    return ez_dictionaryFirst(self, predicate);
}

- (NSArray *)ez_flatMap:(NS_NOESCAPE id (^)(id, id))mapper {
    NSParameterAssert(mapper);
    
    return ez_dictionaryFlatMap(self, mapper);
}

- (void)ez_forEach:(NS_NOESCAPE void (^)(id, id))block {
    NSParameterAssert(block);
    
    ez_dictionaryForEach(self, block);
}

- (NSArray *)ez_map:(NS_NOESCAPE id (^)(id, id))mapper {
    NSParameterAssert(mapper);
    
    return ez_dictionaryMap(self, mapper);
}

- (NSDictionary *)ez_mapValues:(NS_NOESCAPE id (^)(id))mapper {
    NSParameterAssert(mapper);
    
    return ez_dictionaryMapValues(self, mapper);
}

- (nullable id)ez_reduce:(nullable NS_NOESCAPE id)initialValue
                 combine:(NS_NOESCAPE id (^)(id, id, id))reducer {
    NSParameterAssert(reducer);
    
    return ez_dictionaryReduce(self, initialValue, reducer);
}

- (NSArray<NSArray *> *)ez_zip:(id)container {
    NSParameterAssert([self isKindOfClass:[NSDictionary class]]);
    NSParameterAssert([container isKindOfClass:[NSDictionary class]] ||
                      [container isKindOfClass:[NSArray class]] ||
                      [container isKindOfClass:[NSSet class]] ||
                      [container isKindOfClass:[NSOrderedSet class]]);
    
    return ez_zip(self, container);
}

@end
