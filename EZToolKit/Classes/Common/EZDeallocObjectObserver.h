//
//  EZDeallocObjectObserver.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface EZDeallocObjectInfo : NSObject

@property (nonatomic) NSString *classname;
@property (nonatomic) NSString *objAddress;
@end


typedef void (^EZDeallocObjectBlock)(EZDeallocObjectInfo *info);

@interface EZDeallocObjectObserver : NSObject

- (void)addObserverForObject:(id)obj;
- (void)objectHasBeenDeallocated:(EZDeallocObjectBlock)block;

@end

NS_ASSUME_NONNULL_END
