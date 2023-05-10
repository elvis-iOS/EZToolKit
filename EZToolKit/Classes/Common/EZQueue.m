//
//  EZQueue.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/26.
//

#import "EZQueue.h"

@interface EZQueue () {
    NSMutableArray *_container;
}

@end

@implementation EZQueue

- (instancetype)init {
    self = [super init];
    if (self) {
        _container = @[].mutableCopy;
    }
    return self;
}

- (void)inqueue:(id)obj {
    [_container addObject:obj];
}

- (void)inqueueValues:(NSArray *)values {
    [_container addObjectsFromArray:values];
}

- (id)dequeue {
    if ([self isEmpty])
        return nil;
    
    id retVal = [_container firstObject];
    [_container removeObjectAtIndex:0];
    return retVal;
}

- (NSArray *)dequeueFirst:(int)count {
    if ([self isEmpty])
        return nil;
    
    NSMutableArray *retVal = @[].mutableCopy;
    for (int i = 0; i < count; ++i) {
        id v = [self dequeue];
        if (v)
            [retVal addObject:v];
        else
            break;
    }
    
    return retVal.copy;
}

- (void)clear {
    [_container removeAllObjects];
}

- (BOOL)isEmpty {
    return _container.count == 0;
}

@end
