//
//  EZLogger.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/26.
//

#import <Foundation/Foundation.h>
#import "EZMacros.h"
#import "EZFileLogger.h"

#ifndef EZLogger_h
#define EZLogger_h

#define ez_setLogPrefix(prefix) [[EZLogger shared] setLogPrefix:prefix]
#define ez_setLogLevel(level)   [[EZLogger shared] setLogLevel:level]
#define EZLog(level, format, ...)                                                       \
do {                                                                                    \
    NSString *__log_fileName = [NSString stringWithFormat:@"%s",__FILE_NAME__];         \
    NSString *__log_funcName = [NSString stringWithFormat:@"%s",__PRETTY_FUNCTION__];   \
    NSString *__log_line = [NSString stringWithFormat:@"%d",__LINE__];                  \
    NSString *__log_info = [NSString stringWithFormat:@"file:%@ func:%@ line:%@",__log_fileName,__log_funcName,__log_line];                             \
    NSString *__log_log = [NSString stringWithFormat:format, ##__VA_ARGS__];            \
    __log_log = [NSString stringWithFormat:@"%@\n\n%@",__log_log, __log_info];          \
    [[EZLogger shared] logWithLevel:level info:@"%@",__log_log];                        \
} while(0)
#define EZLogTrace(format, ...)  EZLog(EZLogLevelTrace, format, ##__VA_ARGS__)
#define EZLogDebug(format, ...)  EZLog(EZLogLevelDebug, format, ##__VA_ARGS__)
#define EZLogInfo(format, ...)   EZLog(EZLogLevelInfo , format, ##__VA_ARGS__)
#define EZLogWarn(format, ...)   EZLog(EZLogLevelWarn , format, ##__VA_ARGS__)
#define EZLogError(format, ...)  EZLog(EZLogLevelError, format, ##__VA_ARGS__)
#define EZLogFatal(format, ...)  EZLog(EZLogLevelFatal, format, ##__VA_ARGS__)

#endif

NS_ASSUME_NONNULL_BEGIN



@interface EZLogger : NSObject

@property (nonatomic) NSString *logPrefix;
@property (nonatomic) EZLogLevel logLevel;
@property (nonatomic) EZFileLogger *fileLogger;

singletonH

- (void)logWithLevel:(EZLogLevel)logLevel info:(NSString *)format, ...;
@end

NS_ASSUME_NONNULL_END
