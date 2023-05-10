//
//  EZAppManager.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/5/5.
//

#import "EZAppManager.h"
#import "EZCommon.h"
#import "TFHpple.h"

#define getAppProxyValue(proxy, method) ez_callMethodWithReturn(proxy, method, 0)

@implementation EZAppManager

+ (NSArray<EZAppInfo *> *)installedStoreApps {
    return [self _applicationsOfType:0];
}

+ (BOOL)storeAppIsInstalled:(NSString *)bid {
    ez_guardReturnValue(ez_validString(bid), NO);
    
    return [self storeAppInfoForBundle:bid] == nil;
}

+ (EZAppInfo *)storeAppInfoForBundle:(NSString *)bid {
    ez_guardReturnValue(ez_validString(bid), nil);
    
    return [[self installedStoreApps] ez_first:^BOOL(EZAppInfo * _Nonnull app) {
        return [app.bundleID isEqualToString:bid];
    }];
}

+ (EZAppInfo *)storeAppInfoForItem:(NSNumber *)itemID {
    ez_guardReturnValue(ez_validNumber(itemID), nil);
    
    return [[self installedStoreApps] ez_first:^BOOL(EZAppInfo * _Nonnull app) {
        return [app.storeItemID isEqualToNumber:itemID];
    }];
}

+ (void)queryStoreAppInfoForItem:(NSNumber *)itemID
                  country:(NSString *)country
               completion:(nullable EZAppInfoQueryHandler)completion {
    ez_guard(ez_validNumber(itemID)) {
        if (completion) completion(nil);
        return;
    }
    ez_guard(ez_validString(country)) {
        if (completion) completion(nil);
        return;
    }
    
    static NSString *URLString = @"https://itunes.apple.com/lookup";
    NSDictionary *params = @{
        @"id": itemID,
        @"country": country,
        @"lang": @"en_us",
    };
    __block EZAppInfo *retVal = [[EZAppInfo alloc] init];
    [[EZHTTPRequest shared] getRequestWithURLString:URLString
                                             params:params
                                         completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error || !data) {
            if (completion) completion(nil);
            return;
        }
        
        NSDictionary *info = ez_JSONObjectWithData(data);
        NSDictionary *firstResult = [info[@"results"] firstObject];
        if (!ez_validDictionary(firstResult)) {
            if (completion) completion(nil);
            return;
        }
        
        retVal.bundleID = firstResult[@"bundleId"];
        retVal.storeItemID = firstResult[@"trackId"];
        retVal.name = firstResult[@"trackName"];
        retVal.shortVersion = firstResult[@"version"];
        
        NSString *trackViewURL = firstResult[@"trackViewUrl"];
        [[EZHTTPRequest shared] getRequestWithURLString:trackViewURL params:nil completion:^(NSData * _Nullable data1, NSURLResponse * _Nullable response1, NSError * _Nullable error1) {
            if (error1 || !data1) {
                if (completion) completion(retVal);
                return;
            }
            
            TFHpple *doc = [TFHpple hppleWithHTMLData:data1];
            NSArray *elements = [doc searchWithXPathQuery:@"//script[@id='shoebox-media-api-cache-apps']"];
            if (elements.count != 1) {
                if (completion) completion(retVal);
                return;
            }
            
            TFHppleElement *target = elements[0];
            NSDictionary *detail = ez_objFromJSONString(target.content);
            [detail enumerateKeysAndObjectsUsingBlock:^(NSString *key, id JSONString, BOOL * stop) {
                if (![key containsString:[itemID stringValue]])
                    return;
                NSDictionary *detailInfo = ez_objFromJSONString(JSONString);
                NSDictionary *d0 = [[detailInfo valueForKey:@"d"] firstObject];
                NSNumber *extVrsId = [[[[d0 valueForKey:@"attributes"] valueForKey:@"platformAttributes"] valueForKey:@"ios"] valueForKey:@"externalVersionId"];
                if (ez_validNumber(extVrsId)) {
                    retVal.externalVersionID = extVrsId;
                    *stop = YES;
                }
            }];
            if (completion) completion(retVal);
        }];
    }];
}

#pragma mark -
+ (NSArray<EZAppInfo *> *)_applicationsOfType:(int)type {
    id workspace = ez_callMethodWithReturn(NSClassFromString(@"LSApplicationWorkspace"), @"defaultWorkspace", 0);
    NSArray *appProxies = ez_callMethodWithReturn(workspace, @"applicationsOfType:", 1, type);
    
    let retVal = [appProxies ez_map:^EZAppInfo *(id proxy) {
        EZAppInfo *appInfo = [[EZAppInfo alloc] init];
        appInfo.bundleID = getAppProxyValue(proxy, @"applicationIdentifier");
        appInfo.storeItemID = getAppProxyValue(proxy, @"itemID");
        appInfo.sandboxPath = [((NSURL *)getAppProxyValue(proxy, @"dataContainerURL")) path];
        appInfo.bundlePath = [((NSURL *)getAppProxyValue(proxy, @"bundleContainerURL")) path];
        appInfo.name = getAppProxyValue(proxy, @"localizedName");
        appInfo.executableName = getAppProxyValue(proxy, @"bundleExecutable");
        appInfo.externalVersionID = getAppProxyValue(proxy, @"externalVersionIdentifier");
        appInfo.idfv = getAppProxyValue(proxy, @"deviceIdentifierForVendor");
        appInfo.shortVersion = getAppProxyValue(proxy, @"shortVersionString");
        appInfo.version = getAppProxyValue(proxy, @"bundleVersion");
        appInfo.groupContainerURLs = getAppProxyValue(proxy, @"groupContainerURLs");
        
        BOOL isPlaceholder;
        ez_callMethod(proxy, @"isPlaceholder", &isPlaceholder, 0);
        appInfo.isPlaceholder = isPlaceholder;
        
        BOOL isRedownload;
        ez_callMethod(proxy, @"isPurchasedReDownload", &isRedownload, 0);
        appInfo.isRedownload = isRedownload;
        
        return appInfo;
    }];
    
    return retVal;
}

@end
