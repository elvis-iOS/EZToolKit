//
//  EZFileLogger.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/5/4.
//

#import "EZFileLogger.h"
#import "EZObjectInfo.h"
#import "EZFileManager.h"
#import "EZSwiftyType.h"
#import "NSArray+EZFunctional.h"
#import "EZUtil.h"
#import "EZLogger.h"

@interface EZFileLogger ()
@property (nonatomic) NSString *logFile;
@end

@implementation EZFileLogger

+ (instancetype)fileLoggerWithLevel:(EZLogLevel)logLevel logDir:(NSString *)dirPath maxSize:(NSUInteger)maxSize maxAge:(NSTimeInterval)age {
    ez_guardReturnValue(ez_validString(dirPath), nil);
    
    EZFileLogger *instance = [[EZFileLogger alloc] init];
    if (instance) {
        instance.logFileLevel = logLevel;
        instance.logDir = dirPath;
        instance.maxSize = maxSize;
        instance.maxAge = age;
        instance.logFile = [instance _setupLogFile];
    }
    
    return instance;
}

- (NSString *)currentLogFilePath {
    return self.logFile;
}

- (void)writeLog:(NSString *)log {
    static NSFileHandle *fh;
    if (!fh) {
        fh = [NSFileHandle fileHandleForWritingAtPath:self.logFile];
    }
    
    NSUInteger fileSize = [fh seekToEndOfFile];
    if (fileSize >= _maxSize) {
        self.logFile = [self _newLogFile:[NSDate date]];
        [EZFileManager createFile:self.logFile];
        fh = [NSFileHandle fileHandleForWritingAtPath:self.logFile];
    }
    
    NSString *logStr = [NSString stringWithFormat:@"%@    %@\n",ez_nowString(), log];
    [fh writeData:[logStr dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark -
- (NSString *)_newLogFile:(NSDate *)date {
    NSString *filename = [self.logDir stringByAppendingFormat:@"/log_%@.txt", ez_dateToString(date, @"MMdd_HHmmss_SSS")];
    return filename;
}

- (NSString *)_setupLogFile {
    NSURL *dirURL = [NSURL fileURLWithPath:self.logDir];
    NSDate *now = [NSDate date];
    NSArray *directoryContent =
    [[NSFileManager defaultManager] contentsOfDirectoryAtURL:dirURL
                                  includingPropertiesForKeys:@[NSURLContentModificationDateKey, NSURLIsDirectoryKey, NSURLCreationDateKey, NSURLFileSizeKey]
                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                       error:nil];
    
    directoryContent = [directoryContent ez_filter:^BOOL(NSURL *fileURL) {
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if ([isDirectory boolValue])
            return NO;
        
        NSDate *fileDate;
        [fileURL getResourceValue:&fileDate forKey:NSURLCreationDateKey error:nil];
        NSTimeInterval age = [now timeIntervalSinceDate:fileDate];
        if (age >= self.maxAge) {
            [EZFileManager removeFile:[fileURL path]];
            return NO;
        }
        
        NSNumber *fileSize;
        [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:nil];
        if ([fileSize unsignedIntegerValue] >= self.maxSize)
            return NO;
        
        return YES;
    }];
    
    NSArray *sortedContent = [directoryContent sortedArrayUsingComparator: ^(NSURL *file1, NSURL *file2) {
        // compare
        NSDate *file1Date;
        [file1 getResourceValue:&file1Date forKey:NSURLContentModificationDateKey error:nil];
        
        NSDate *file2Date;
        [file2 getResourceValue:&file2Date forKey:NSURLContentModificationDateKey error:nil];
        
        return [file2Date compare: file1Date];
    }];
    
    NSString *filename = [self _newLogFile:now];
    if (!ez_validArray(sortedContent)) {
        [EZFileManager createFile:filename];
        return filename;
    }
    
    NSString *path = [((NSURL *)[sortedContent firstObject]) path];
    let attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSDate *modDate = attributes[NSFileModificationDate];
    NSNumber *fileSize = attributes[NSFileSize];
    
    NSTimeInterval age = [[NSDate date] timeIntervalSinceDate:modDate];
    if (age < self.maxAge && [fileSize unsignedIntegerValue] < self.maxSize) {
        return path;
    }
    
    [EZFileManager createFile:filename];
    return filename;
}

@end
