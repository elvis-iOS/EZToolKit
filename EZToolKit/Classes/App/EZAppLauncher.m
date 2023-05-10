//
//  EZAppLauncher.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/5/9.
//

#import "EZAppLauncher.h"
#import "EZCommon.h"

#include <dlfcn.h>

#define kPath_FrontBoardServices "/System/Library/PrivateFrameworks/FrontBoardServices.framework/FrontBoardServices"
#define KPath_MobileInstallation "/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation"

@implementation EZAppLauncher

+ (BOOL)openApp:(NSString *)bundleID {
    ez_guardReturnValue(ez_validString(bundleID), NO);
    
    id workspace = ez_callMethodWithReturn(NSClassFromString(@"LSApplicationWorkspace"), @"defaultWorkspace", 0);
    BOOL retVal;
    ez_callMethod(workspace, @"openApplicationWithBundleID:", &retVal, 1, bundleID);
    return retVal;
}

+ (BOOL)closeApp:(NSString *)bundleID {
    ez_guardReturnValue(ez_validString(bundleID), NO);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dlopen("/System/Library/PrivateFrameworks/FrontBoardServices.framework/FrontBoardServices", RTLD_LAZY);
    });
    
    id service = ez_callMethodWithReturn(NSClassFromString(@"FBSSystemService"), @"sharedService", 0);
    pid_t pid;
    ez_callMethod(service, @"pidForApplication:", &pid, 1, bundleID);
    if (pid <= 0)
        return NO;
    
    ez_callMethod(service, @"terminateApplication:forReason:andReport:withDescription:", NULL, 4, bundleID, 1, NO, nil);
    return YES;
}

+ (BOOL)uninstallApp:(NSString *)bundleID {
    ez_guardReturnValue(ez_validString(bundleID), NO);
    
    id workspace = ez_callMethodWithReturn(NSClassFromString(@"LSApplicationWorkspace"), @"defaultWorkspace", 0);
    BOOL retVal;
    ez_callMethod(workspace, @"uninstallApplication:withOptions:", &retVal, 2, bundleID, nil);
    return retVal;
}

typedef int (*MobileInstallationInstall)(NSString *path, NSDictionary *dict, void *na, NSString *backpath);
+ (BOOL)installApp:(NSString *)ipaPath withBundleID:(NSString *)bundleID {
    ez_guardReturnValue(ez_validString(ipaPath), NO);
    ez_guardReturnValue(ez_validString(bundleID), NO);
    ez_guardReturnValue([[NSFileManager defaultManager] fileExistsAtPath:ipaPath], NO);
    
    BOOL retVal = NO;
//    if (kCFCoreFoundationVersionNumber < 1140.10) {
//        void *lib = dlopen(KPath_MobileInstallation, RTLD_LAZY);
//        if (lib) {
//            MobileInstallationInstall install = (MobileInstallationInstall)dlsym(lib, "MobileInstallationInstall");
//            if (install) {
//                retVal = install(ipaPath, @{@"ApplicationType": @"User"}, 0, ipaPath) == 0;
//            }
//            dlclose(lib);
//        }
//        return retVal;
//    }
    
    id workspace = ez_callMethodWithReturn(NSClassFromString(@"LSApplicationWorkspace"), @"defaultWorkspace", 0);
    NSError *error;
    ez_callMethod(workspace,
                  @"installApplication:withOptions:error:",
                  &retVal,
                  3,
                  [NSURL fileURLWithPath:ipaPath],
                  @{@"CFBundleIdentifier": bundleID},
                  &error);
    if (error) {
        EZLogError(@"Failed to install ipa %@ from path %@. error is %@", bundleID, ipaPath, error);
    }
    return retVal;
}

@end
