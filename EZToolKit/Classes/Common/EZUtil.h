//
//  EZUtil.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/25.
//

#ifndef EZUtil_h
#define EZUtil_h

#import <Foundation/Foundation.h>

// string
NSString * ez_safeString(NSString *val);
BOOL ez_stringEqual(NSString *str1, NSString *str2);
BOOL ez_stringHasPrefix(NSString *str, NSString *prefix);
BOOL ez_stringContains(NSString *str1, NSString *str2);

// error
NSError * ez_error(NSString *domainName,
                           NSInteger code,
                           NSError *underlyingError,
                           NSString *format, ...);

// JSON
NSString * ez_JSONStringFromObj(id obj);
id ez_objFromJSONString(NSString *JSONStr);
id ez_JSONObjectWithData(NSData *data);

// view
CGRect ez_viewRectInScreen(UIView *view);
CGPoint ez_randomPointInRect(CGRect rect);

// dispatch
dispatch_source_t ez_dispatchTimer(dispatch_queue_t queue,
                                    NSTimeInterval interval,
                                    void (^timerBlock)(void));
void ez_dispatchTimerAuto(NSTimeInterval interval, void (^timerBlock)(dispatch_source_t timer));
void ez_dispatchAfter(NSTimeInterval interval, void (^afterBlock)(void));

// date
NSString * ez_dateToString(NSDate *date, NSString *dateFormat);
NSDate * ez_dateFromString(NSString *dateString, NSString *dateFormat);
// yyyy-MM-dd HH:mm:ss
NSString * ez_nowString(void);
// yyyy-MM-dd HH:mm:ss:SSS
NSString * ez_nowStringDetail(void);

#endif
