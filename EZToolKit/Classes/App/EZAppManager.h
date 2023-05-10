//
//  EZAppManager.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/5/5.
//

#import <Foundation/Foundation.h>
#import "EZAppInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^EZAppInfoQueryHandler)(EZAppInfo * _Nullable appInfo);

@interface EZAppManager : NSObject

+ (NSArray<EZAppInfo *> *)installedStoreApps;
+ (BOOL)storeAppIsInstalled:(NSString *)bid;
+ (EZAppInfo *)storeAppInfoForBundle:(NSString *)bid;
+ (EZAppInfo *)storeAppInfoForItem:(NSNumber *)itemID;
+ (void)queryStoreAppInfoForItem:(NSNumber *)itemID country:(NSString *)country completion:(nullable EZAppInfoQueryHandler)completion;


@end

NS_ASSUME_NONNULL_END
