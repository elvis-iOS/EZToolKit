//
//  EZFileLogger.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/5/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, EZLogLevel) {
    EZLogLevelTrace,
    EZLogLevelDebug,
    EZLogLevelInfo,
    EZLogLevelWarn,
    EZLogLevelError,
    EZLogLevelFatal
};

@interface EZFileLogger : NSObject

@property (nonatomic) EZLogLevel logFileLevel;
@property (nonatomic) NSString *logDir;
@property (nonatomic) NSTimeInterval maxAge;
@property (nonatomic) NSUInteger maxSize;

+ (instancetype)fileLoggerWithLevel:(EZLogLevel)logLevel logDir:(NSString *)dirPath maxSize:(NSUInteger)maxSize maxAge:(NSTimeInterval)age;
- (NSString *)currentLogFilePath;
- (void)writeLog:(NSString *)log;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
