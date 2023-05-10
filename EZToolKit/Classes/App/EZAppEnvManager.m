//
//  EZAppEnvManager.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/5/9.
//

#import "EZAppEnvManager.h"
#import "EZCommon.h"
#import "EZAppManager.h"

@implementation EZKeychainItem

- (NSDictionary *)dictionaryRepresentaion {
    
    /**
     key: kSecAttrAccessible
     value: ck      ->      kSecAttrAccessibleAfterFirstUnlock
     value: cku    ->      kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
     value: dk      ->      kSecAttrAccessibleAlways
     value: akpu  ->      kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
     value: dku    ->      kSecAttrAccessibleAlwaysThisDeviceOnly
     value: ak      ->      kSecAttrAccessibleWhenUnlocked
     value: aku    ->      kSecAttrAccessibleWhenUnlockedThisDeviceOnly
     */
    
    NSMutableDictionary *kcFetch = @{}.mutableCopy;
    [kcFetch setValue:_acct forKey:(id)kSecAttrAccount];
    [kcFetch setValue:_agrp forKey:(id)kSecAttrAccessGroup];
    [kcFetch setValue:_svce forKey:(id)kSecAttrService];
    [kcFetch setValue:_pdmn forKey:(id)kSecAttrAccessible];
    [kcFetch setValue:_v_Data forKey:(id)kSecValueData];
    [kcFetch setValue:_gena forKey:(id)kSecAttrGeneric];
    return kcFetch.copy;
}

@end

@implementation EZAppEnvManager

- (instancetype)initWithBundleID:(NSString *)bundleID {
    self = [super init];
    if (self) {
        self.bundleID = bundleID;
    }
    
    return self;
}

#pragma mark - Sandbox
- (NSString *)sandboxPath {
    ez_guardReturnValue(ez_validString(_bundleID), nil);
    return [EZAppManager storeAppInfoForBundle:_bundleID].sandboxPath;
}

- (BOOL)cleanSandboxWithWhitelist:(NSArray<NSString *> *)whitelist {
    ez_guardReturnValue(ez_validString(_bundleID),NO);
    
    NSString *sandboxPath = [self sandboxPath];
    ez_guardReturnValue(ez_validString(sandboxPath), NO);
    
    NSMutableArray *wl = @[@".com.apple.mobile_container_manager.metadata.plist"].mutableCopy;
    if (ez_validArray(whitelist))
        [wl addObjectsFromArray:whitelist];
    
    NSArray<NSString *> *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:sandboxPath error:nil];
    [contents ez_forEach:^(NSString * _Nonnull cnt) {
        // 跳过白名单中的文件
        __block BOOL shouldSkip = NO;
        [whitelist ez_forEach:^(NSString * _Nonnull wlist) {
            NSMutableArray *paths = @[].mutableCopy;
            [[wlist pathComponents] ez_reduce:@"" combine:^id (NSString *accumulator, NSString *value) {
                NSString *retVal = [accumulator stringByAppendingPathComponent:value];
                [paths addObject:retVal];
                return retVal;
            }];
            [paths enumerateObjectsUsingBlock:^(id  _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([path containsString:@"*"]) {
                    NSString *regular = [path stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
                    if ([predicate evaluateWithObject:cnt]) {
                        shouldSkip = YES;
                        *stop = YES;
                    }
                    return;
                }
                
                if ([path isEqualToString:cnt]) {
                    shouldSkip = YES;
                    *stop = YES;
                }
            }];
        }];
        if (shouldSkip)
            return;
        
        [EZFileManager removeFile:[sandboxPath stringByAppendingPathComponent:cnt]];
    }];
    
    return YES;
}

#pragma mark - AppGroup
- (NSArray<NSString *> *)appGroupPaths {
    ez_guardReturnValue(ez_validString(_bundleID), nil);
    return [[EZAppManager storeAppInfoForBundle:_bundleID].groupContainerURLs.allValues ez_map:^id _Nullable(NSURL *v) {
        return [v path];
    }];
}

- (BOOL)cleanAppGroup:(NSString *)appGroupID {
    ez_guardReturnValue(ez_validString(_bundleID), NO);
    NSString *path = [[[EZAppManager storeAppInfoForBundle:_bundleID].groupContainerURLs valueForKey:appGroupID] path];
    ez_guardReturnValue(ez_validString(path), NO);
    
    [EZFileManager removeFile:[path stringByAppendingPathComponent:@"*"]];
    return YES;
}

- (BOOL)cleanAllAppGroups {
    ez_guardReturnValue(ez_validString(_bundleID), NO);
    
    [[self.appGroupPaths ez_map:^id _Nullable(NSString *v) {
        return [v stringByAppendingPathComponent:@"*"];
    }] ez_forEach:^(id  _Nonnull value) {
        [EZFileManager removeFile:value];
    }];
    return YES;
}

#pragma mark - Pasteboard
- (NSString *)pasteboardPath {
    ez_guardReturnValue(ez_validString(_bundleID), nil);
    
    static NSString *PasteboardDBDirectoryPath = @"/var/mobile/Library/Caches/com.apple.Pasteboard/";
    NSArray *subDirPaths =  [[NSFileManager defaultManager] contentsOfDirectoryAtPath:PasteboardDBDirectoryPath error:nil];
    for (NSString *subDir in subDirPaths) {
        NSString *dirPath =  [NSString stringWithFormat:@"%@%@",PasteboardDBDirectoryPath,subDir];
        NSString *manifestPlistPath = [dirPath stringByAppendingPathComponent:@"Manifest.plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:manifestPlistPath];
        if (!ez_validData(plistData))
            continue;
        
        NSDictionary *dic = [NSPropertyListSerialization propertyListWithData:plistData options:0 format:NULL error:nil];
        NSArray *objects = [dic valueForKey:@"$objects"];
        for (id obj in objects) {
            if (![obj isKindOfClass:[NSString class]])
                continue;
            
            if ([obj isEqualToString:_bundleID])
                return dirPath;
        }
    }
    
    return nil;
}

- (BOOL)cleanPasteboard {
    ez_guardReturnValue(ez_validString(_bundleID), NO);
    
    NSString *path = [self pasteboardPath];
    ez_guardReturnValue(ez_validString(path), NO);
    
    [EZFileManager removeFile:[path stringByAppendingPathComponent:@"*"]];
    return YES;
}



@end
