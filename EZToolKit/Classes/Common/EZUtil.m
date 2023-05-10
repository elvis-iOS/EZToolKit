//
//  EZUtil.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/25.
//

#import "EZUtil.h"
#import "EZObjectInfo.h"

NSString *ez_safeString(NSString *val) {
    return ez_validString(val) ? val : @"";
}

BOOL ez_stringEqual(NSString *str1, NSString *str2) {
    return [str1.lowercaseString isEqualToString:str2.lowercaseString];
}

BOOL ez_stringHasPrefix(NSString *str, NSString *prefix) {
    return [str.lowercaseString hasPrefix:prefix.lowercaseString];
}

BOOL ez_stringContains(NSString *str1, NSString *str2) {
    return [str1.lowercaseString containsString:str2.lowercaseString];
}

NSError * ez_error(NSString *domainName,
                           NSInteger code,
                           NSError *underlyingError,
                   NSString *format, ...) {
    static NSString *ezErrorDomain = @"ezErrorDomain";
    NSString *r_domainName = ez_validString(domainName) ? domainName : ezErrorDomain;
    
    va_list valist;
    va_start(valist, format);
    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:valist];
    va_end(valist);
    
    NSMutableDictionary *realUserInfo = @{}.mutableCopy;
    realUserInfo[NSLocalizedDescriptionKey] = formatStr;
    if (underlyingError) {
        [realUserInfo setValue:underlyingError forKey:NSUnderlyingErrorKey];
    }
    
    return [NSError errorWithDomain:r_domainName code:code userInfo:realUserInfo.copy];
}

NSString * ez_JSONStringFromObj(id obj) {
    if (![NSJSONSerialization isValidJSONObject:obj])
        return nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    if (!data) return nil;
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

id ez_objFromJSONString(NSString *JSONStr) {
    if (!ez_validString(JSONStr))
        return nil;
    
    NSData *d = [JSONStr dataUsingEncoding:NSUTF8StringEncoding];
    if (!ez_validData(d))
        return nil;
    
    return [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
}

id ez_JSONObjectWithData(NSData *data) {
    if (!ez_validData(data))
        return nil;
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

CGRect ez_viewRectInScreen(UIView *view) {
    return [[view superview] convertRect:view.frame toView:[[UIApplication sharedApplication] keyWindow]];
}

CGPoint ez_randomPointInRect(CGRect rect) {
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    uint32_t width = CGRectGetWidth(rect);
    uint32_t height = CGRectGetHeight(rect);
    
    CGFloat x = arc4random() % width + minX;
    CGFloat y = arc4random() % height + minY;
    return CGPointMake(x, y);
}

dispatch_source_t ez_dispatchTimer(dispatch_queue_t queue, NSTimeInterval interval, void (^timerBlock)(void)) {
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        
        if (timerBlock)
            timerBlock();
    });
    
    return timer;
}

void ez_dispatchTimerAuto(NSTimeInterval interval, void (^timerBlock)(dispatch_source_t timer)) {
    static dispatch_source_t timer;
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_queue_create(NULL, 0));
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, interval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        
        if (timerBlock)
            timerBlock(timer);
    });
    
    dispatch_resume(timer);
}

void ez_dispatchAfter(NSTimeInterval interval, void (^afterBlock)(void)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (afterBlock) afterBlock();
    });
}

NSString * ez_dateToString(NSDate *date, NSString *dateFormat) {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:dateFormat];
    return [df stringFromDate:date];
}

NSDate * ez_dateFromString(NSString *dateString, NSString *dateFormat) {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:dateFormat];
    return [df dateFromString:dateString];
}

NSString * ez_nowString(void) {
    return ez_dateToString([NSDate date], @"yyyy-MM-dd HH:mm:ss");
}

NSString * ez_nowStringDetail(void) {
    return ez_dateToString([NSDate date], @"yyyy-MM-dd HH:mm:ss:SSS");
}
