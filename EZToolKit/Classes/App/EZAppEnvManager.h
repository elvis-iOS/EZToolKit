//
//  EZAppEnvManager.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EZKeychainItem : NSObject

@property (nonatomic, strong) id acct;
@property (nonatomic, strong) id agrp;
@property (nonatomic, strong, nullable) id gena;
@property (nonatomic, strong) id svce;
@property (nonatomic, strong) id pdmn;
@property (nonatomic, strong) id v_Data;

- (NSDictionary *)dictionaryRepresentaion;
@end

@interface EZAppEnvManager : NSObject

@property (nonatomic) NSString *bundleID;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithBundleID:(NSString *)bundleID;

// ====== Sandbox ======
- (NSString *)sandboxPath;
///
///@param whitelist 白名单，值为相对文件路径
- (BOOL)cleanSandboxWithWhitelist:(nullable NSArray<NSString *> *)whitelist;

// ====== AppGroup ======
- (NSArray<NSString *> *)appGroupPaths;
- (BOOL)cleanAppGroup:(NSString *)appGroupID;
- (BOOL)cleanAllAppGroups;

// ====== Pasteboard ======
- (NSString *)pasteboardPath;
- (BOOL)cleanPasteboard;

// ====== Keychain ======
- (NSArray<NSString *> *)keychainAccessGroups;
- (NSArray<EZKeychainItem *> *)keychainItems;
- (BOOL)removeKeychainItem:(EZKeychainItem *)item;
- (BOOL)removeKeyAllKeychainItems;
- (BOOL)insertKeychainItem:(EZKeychainItem *)item;

///
///清理应用使用痕迹
- (BOOL)cleanApp;

@end

NS_ASSUME_NONNULL_END
