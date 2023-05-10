//
//  EZAppInfo.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/5/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZAppInfo : NSObject

@property (nonatomic) NSString *bundleID;
@property (nonatomic) NSNumber *storeItemID;
@property (nonatomic) NSString *sandboxPath;
@property (nonatomic) NSString *bundlePath;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *executableName;
@property (nonatomic) NSNumber *externalVersionID;
@property (nonatomic) NSString *idfv;
@property (nonatomic) NSDictionary<NSString *, NSURL *> *groupContainerURLs;
@property (nonatomic) NSString *shortVersion;
@property (nonatomic) NSString *version;
@property (nonatomic) BOOL isPlaceholder;
@property (nonatomic) BOOL isRedownload;
@end

NS_ASSUME_NONNULL_END
