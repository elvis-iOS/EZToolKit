//
//  NSObject+EZFunctional.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/25.
//

#import "NSArray+EZFunctional.h"

static BOOL ez_isSameKindContainers(id c1, id c2) {
    if (![c1 isKindOfClass:[NSArray class]] ||
        ![c1 isKindOfClass:[NSSet class]] ||
        ![c1 isKindOfClass:[NSOrderedSet class]])
        return NO;
    
    return [c1 isKindOfClass:[c2 class]];
}

static NSArray *ez_arrayFromContainer(id c) {
    NSArray *retVal = @[];
    if ([c isKindOfClass:[NSArray class]])
        retVal = c;
    
    else if ([c isKindOfClass:[NSSet class]])
        retVal = [c allValues];
    
    else if ([c isKindOfClass:[NSOrderedSet class]])
        retVal = [c array];
    
    return retVal;
}

static NSArray * ez_map(id<NSFastEnumeration> container, id _Nullable (^mapper)(id)) {
    NSMutableArray *retVal = [NSMutableArray array];
    for (id obj in container) {
        id mapped = mapper(obj);
        [retVal addObject: mapped ?: [NSNull null]];
    }
    
    return retVal;
}

static NSArray * ez_flatMap(id<NSFastEnumeration> container, id _Nullable (^mapper)(id)) {
    NSMutableArray *retVal = [NSMutableArray array];
    for (id obj in container) {
        id mapped = mapper(obj);
        if (ez_isSameKindContainers(container, mapper)) {
            [retVal addObjectsFromArray:ez_arrayFromContainer(mapped)];
        }
        else if (mapped) {
            [retVal addObject:mapped];
        }
    }
    
    return retVal;
}

static id ez_filter(id<NSFastEnumeration, NSObject> container, BOOL (^predicate)(id)) {
    id result = [[[container class] new] mutableCopy];
    for (id object in container) {
        if (predicate(object)) {
            [result addObject:object];
        }
    }
    return result;
}

static id __nullable ez_first(id<NSFastEnumeration> container, BOOL (^predicate)(id)) {
    for (id object in container) {
        if (predicate(object)) {
            return object;
        }
    }
    return nil;
}

static void ez_forEach(id<NSFastEnumeration> container, void (^block)(id)) {
    for (id object in container) {
        block(object);
    }
}

static id __nullable ez_reduce(id<NSFastEnumeration> container,
                               id __nullable initialValue,
                               id __nullable (^reducer)(id __nullable, id)) {
    id result = initialValue;
    for (id object in container) {
        result = reducer(result, object);
    }
    return result;
}

NSArray<NSArray *> *ez_zip(id container1, id container2) {
    NSMutableArray<NSArray *> *result = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator1 = [container1 objectEnumerator];
    NSEnumerator *enumerator2 = [container2 objectEnumerator];
    for (;;) {
        id object1 = [enumerator1 nextObject];
        id object2 = [enumerator2 nextObject];
        if (!object1 || !object2) break;
        [result addObject:@[ object1, object2 ]];
    }
    return result;
}

@implementation NSObject (EZFunctional)

- (NSArray *)ez_map:(EZArrayMapBlock)mapper {
    NSParameterAssert([self isKindOfClass:[NSArray class]] ||
                      [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(mapper);
    
    return ez_map((id<NSFastEnumeration>)self, mapper);
}

- (NSArray *)ez_flatMap:(EZArrayMapBlock)mapper {
    NSParameterAssert([self isKindOfClass:[NSArray class]] ||
                      [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(mapper);
    
    return ez_flatMap((id<NSFastEnumeration>)self, mapper);
}

- (instancetype)ez_filter:(EZArrayPredicateBlock)predicate {
    NSParameterAssert([self isKindOfClass:[NSArray class]] ||
                      [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(predicate);
    
    return ez_filter((id<NSFastEnumeration, NSObject>)self, predicate);
}

- (nullable id)ez_first:(BOOL (^)(id))predicate {
    NSParameterAssert([self isKindOfClass:[NSArray class]] ||
                      [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(predicate);
    
    return ez_first((id<NSFastEnumeration>)self, predicate);
}

- (void)ez_forEach:(void (^)(id))block {
    NSParameterAssert([self isKindOfClass:[NSArray class]] ||
                      [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(block);
    
    ez_forEach((id<NSFastEnumeration>)self, block);
}

- (nullable id)ez_reduce:(nullable id)initialValue combine:(id (^)(id, id))reducer {
    NSParameterAssert([self isKindOfClass:[NSArray class]] ||
                      [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert(reducer);
    
    return ez_reduce((id<NSFastEnumeration>)self, initialValue, reducer);
}

- (NSArray<NSArray *> *)ez_zip:(id)container {
    NSParameterAssert([self isKindOfClass:[NSArray class]] ||
                      [self isKindOfClass:[NSSet class]] ||
                      [self isKindOfClass:[NSOrderedSet class]]);
    NSParameterAssert([container isKindOfClass:[NSArray class]] ||
                      [container isKindOfClass:[NSSet class]] ||
                      [container isKindOfClass:[NSOrderedSet class]]);
    
    return ez_zip(self, container);
}

@end
