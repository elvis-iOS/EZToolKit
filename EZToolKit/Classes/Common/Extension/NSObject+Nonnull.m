//
//  NSObject+Nonnull.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/3/28.
//

#import "NSObject+Nonnull.h"

#import <objc/runtime.h>

@implementation NSObject (Nonnull)

+ (NSArray *)ez_exceptionsKeys {
    return @[];
}

+ (NSArray *)ez_subKeys {
    return @[];
}

- (BOOL)ez_isNonnull {
    BOOL flag = YES;
    unsigned int outCount;
    objc_property_t *propertyList = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; ++i) {
        NSString *pname = [NSString stringWithCString:property_getName(propertyList[i]) encoding:NSUTF8StringEncoding];
        if ([[[self class] ez_exceptionsKeys] containsObject:pname])
            continue;
        id value = [self valueForKey:pname];
        if (!value) {
            flag = NO;
            break;
        }
        
        if ([[[self class] ez_subKeys] containsObject:pname] &&
            [value respondsToSelector:@selector(ez_isNonnull)]) {
            if (![value ez_isNonnull]) {
                flag = NO;
                break;;
            }
        }
    }
    
    return flag;
}

@end
