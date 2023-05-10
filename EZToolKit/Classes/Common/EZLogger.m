//
//  EZLogger.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/26.
//

#import "EZLogger.h"
#import "EZObjectInfo.h"
#import "EZFileLogger.h"

@implementation EZLogger

singletonM(EZLogger)

- (instancetype)init {
    self = [super init];
    if (self) {
        _logPrefix = @"";
    }
    return self;
}

- (void)logWithLevel:(EZLogLevel)logLevel info:(NSString *)format, ... {
    va_list valist;
    va_start(valist, format);
    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:valist];
    va_end(valist);
    
    ez_guardReturn(logLevel >= _logLevel && logLevel <= 5);
    
    NSString *prefix = [NSString stringWithFormat:@"%@%@", _logPrefix, [[self class] _logLevelString:logLevel]];
    if (logLevel >= _fileLogger.logFileLevel) {
        NSString *fileLogStr = [NSString stringWithFormat:@"%@%@", prefix, formatStr];
        [_fileLogger writeLog:fileLogStr];
    }
    NSUInteger sub_len = 800 - prefix.length;
    NSUInteger str_len = [formatStr length];
    for (int i = 0; i < str_len; i += sub_len) {
        NSRange range;
        if (str_len - i > sub_len) {
            range = NSMakeRange(i, sub_len);
        } else {
            range = NSMakeRange(i, str_len - i);
        }
        NSLog(@"%@%@", prefix ,[formatStr substringWithRange:range]);
    }
}

#pragma mark -
+ (NSString *)_logLevelString:(EZLogLevel)logLevel {
    switch (logLevel) {
        case EZLogLevelTrace : return @"【TRACE】";
        case EZLogLevelDebug : return @"【DEBUG】";
        case EZLogLevelInfo  : return @"【INFO】";
        case EZLogLevelWarn  : return @"【WARN】";
        case EZLogLevelError : return @"【ERROR】";
        case EZLogLevelFatal : return @"【FATAL】";
        default              : return @"【UNKNOWN】";
    }
}

#pragma mark - Property
- (void)setLogPrefix:(NSString *)prefix {
    ez_guard(ez_validString(prefix)) {
        self->_logPrefix = @"";
        return;
    };
    
    _logPrefix = prefix;
}

- (void)setLogLevel:(EZLogLevel)logLevel {
    ez_guard(logLevel >= 0 && logLevel <= 5) {
        self->_logLevel = EZLogLevelTrace;
        return;
    };
    
    _logLevel = logLevel;
}


@end
