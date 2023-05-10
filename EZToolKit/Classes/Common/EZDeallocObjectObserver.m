//
//  EZDeallocObjectObserver.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/17.
//

#import "EZDeallocObjectObserver.h"
#import <objc/runtime.h>

#pragma mark - EZDeallocObjectInfo
@interface EZDeallocObjectInfo ()
@property (weak, nonatomic) EZDeallocObjectObserver *observer;
@end

@implementation EZDeallocObjectInfo

- (void)dealloc {
    NSMutableArray<EZDeallocObjectBlock> *blocks = [self.observer valueForKey:@"deallocatedBlocks"];
    [blocks enumerateObjectsUsingBlock:^(EZDeallocObjectBlock block, NSUInteger idx, BOOL *stop) {
        block(self);
    }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"classname:%@ address:%@",_classname,_objAddress];
}

@end

#pragma mark - EZDeallocObjectObserver
@interface EZDeallocObjectObserver()
@property (nonatomic) NSMutableArray<EZDeallocObjectBlock> *deallocatedBlocks;
@end

@implementation EZDeallocObjectObserver

- (void)addObserverForObject:(id)obj {
    if (!obj)
        return;
    
    EZDeallocObjectInfo *objInfo = [[EZDeallocObjectInfo alloc] init];
    objInfo.classname = NSStringFromClass([obj class]);
    objInfo.objAddress = [NSString stringWithFormat:@"%p",obj];
    objInfo.observer = self;
    objc_setAssociatedObject(obj, "com.elvis.deallocObjectInfo", objInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)objectHasBeenDeallocated:(EZDeallocObjectBlock)block {
    if (!block)
        return;
    
    [self.deallocatedBlocks addObject:block];
}

#pragma mark - Properties
- (NSMutableArray *)deallocatedBlocks {
    if (_deallocatedBlocks)
        return _deallocatedBlocks;
    
    _deallocatedBlocks = @[].mutableCopy;
    return _deallocatedBlocks;
}

@end
