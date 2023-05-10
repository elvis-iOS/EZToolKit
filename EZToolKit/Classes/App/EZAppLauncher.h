//
//  EZAppLauncher.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZAppLauncher : NSObject

+ (BOOL)openApp:(NSString *)bundleID;
+ (BOOL)closeApp:(NSString *)bundleID;
+ (BOOL)uninstallApp:(NSString *)bundleID;
+ (BOOL)installApp:(NSString *)ipaPath withBundleID:(NSString *)bundleID;
@end

NS_ASSUME_NONNULL_END
