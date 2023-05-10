//
//  EZFileManager.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/27.
//

#import "EZFileManager.h"
#import "EZObjectInfo.h"
#import "EZSwiftyType.h"
#import <sys/stat.h>

@implementation EZFileManager

singletonM(EZFileManager)

+ (BOOL)createDir:(NSString *)dir {
    ez_guardReturnValue(ez_validString(dir), NO);
    ez_guardReturnValue([[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil], NO);
    [[self class] _setPermission:dir];
    return YES;
}

+ (BOOL)createFile:(NSString *)file {
    ez_guardReturnValue(ez_validString(file), NO);
    
    NSString *dirPath = [file stringByDeletingLastPathComponent];
    ez_guardReturnValue([self createDir:dirPath], NO);
    ez_guardReturnValue([[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil], NO);
    [[self class] _setPermission:file];
    return YES;
}

+ (BOOL)removeFile:(NSString *)fileName {
    ez_guardReturnValue(ez_validString(fileName), NO);
    
    BOOL containsStar = [fileName containsString:@"*"];
    if (!containsStar)
        return [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    
    BOOL retVal = YES;
    NSString *lastPathComponent = fileName.lastPathComponent;
    NSString *regular = [lastPathComponent stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    
    NSString *dirPath = fileName.stringByDeletingLastPathComponent;
    NSArray *fileContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    for (int i = 0; i < fileContents.count; ++i) {
        NSString *subPath = fileContents[i];
        if (![predicate evaluateWithObject:subPath])
            continue;
        
        NSString *fullPath = [dirPath stringByAppendingPathComponent:subPath];
        BOOL flag = [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        if (!flag)
            retVal = flag;
    }
    
    return retVal;
}

- (BOOL)createDir:(NSString *)dir {
    ez_guardReturnValue(ez_validString(dir), NO);
    
    NSString *wholePath = [self.workDir stringByAppendingPathComponent:dir];
    return [[self class] createDir:wholePath];
}

- (BOOL)createFile:(NSString *)file {
    ez_guardReturnValue(ez_validString(file), NO);
    
    NSString *wholePath = [self.workDir stringByAppendingPathComponent:file];
    return [[self class] createFile:wholePath];
}

- (BOOL)removeFile:(NSString *)file {
    ez_guardReturnValue(ez_validString(file), NO);
    
    NSString *wholePath = [self.workDir stringByAppendingPathComponent:file];
    return [[self class] removeFile:wholePath];
}

#pragma mark - Property
- (void)setWorkDir:(NSString *)workDir {
    ez_guardReturn(ez_validString(workDir));
    ez_defer {
        self->_workDir = workDir;
    };
    
    BOOL isExisted = [[NSFileManager defaultManager] fileExistsAtPath:workDir];
    if (isExisted) return;
    
    NSAssert([[self class] createFile:workDir], @"failed to create work dir");
    [[self class] _setPermission:workDir];
}

#pragma mark -
+ (BOOL)_setPermission:(NSString *)path {
    ez_guardReturnValue(chown(path.UTF8String, 501, 501) == 0, NO);
    ez_guardReturnValue(chmod(path.UTF8String, S_IRWXU | S_IRWXG | S_IRWXO) == 0, NO);
    
    return YES;
}

@end
