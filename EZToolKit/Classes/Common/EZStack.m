//
//  EZStack.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/26.
//

#import "EZStack.h"

@interface EZStack () {
    NSMutableArray *_container;
}
@end

@implementation EZStack

- (instancetype)init {
    self = [super init];
    if (self) {
        _container = @[].mutableCopy;
    }
    
    return self;
}

- (void)push:(id)value {
    [_container addObject:value];
}

- (void)pushValues:(NSArray *)values {
    [_container addObjectsFromArray:values];
}

- (id)pop {
    if ([self isEmpty])
        return nil;
    
    id retVal = [_container lastObject];
    [retVal removeLastObject];
    return retVal;
}

- (NSArray *)popFirst:(int)count {
    if ([self isEmpty])
        return nil;
    
    NSMutableArray *retVal = @[].mutableCopy;
    for (int i = 0; i < count; ++count) {
        id v = [self pop];
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
