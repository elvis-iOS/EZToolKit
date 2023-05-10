//
//  NSObject+FMDB.m
//  do
//
//  Created by Elvis on 2021/3/19.
//

#import "NSObject+FMDB.h"

#import <objc/runtime.h>

@implementation NSObject (FMDB)

+ (id)fmdb_modelWithResultSet:(FMResultSet *)result {
    if (!result)
        return nil;
    
    id instance = [[self alloc] init];
    Class cls = [self class];
    do {
        unsigned int outCount;
        Ivar *ivarList = class_copyIvarList(cls, &outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivarList[i];
            [self _handleIvar:ivar forInstance:instance withResultSet:result];
        }
        free(ivarList);
        cls = class_getSuperclass(cls);
    } while (cls != [NSObject class]);
    
    return instance;
}

- (NSDictionary *)fmdb_modelInfo {
    if (!self)
        return nil;
    
    NSMutableDictionary *myKvInfos = nil;
    Class cls = [self class];
    do {
        unsigned int outCount;
        Ivar *ivarList = class_copyIvarList(cls, &outCount);
        for (int i = 0; i < outCount; ++i) {
            Ivar ivar = ivarList[i];
            NSDictionary *kvInfo = [self _kvInfoWithIvar:ivar];
            if (kvInfo) {
                if (!myKvInfos)
                    myKvInfos = @{}.mutableCopy;
                
                [myKvInfos addEntriesFromDictionary:kvInfo];
            }
        }
        free(ivarList);
        cls = class_getSuperclass(cls);
    } while (cls != [NSObject class]);
    
    return myKvInfos.copy;
}

#pragma mark - Private
- (NSDictionary *)_kvInfoWithIvar:(Ivar)ivar {
    if (ivar == NULL)
        return nil;
    
    const char *ivName = ivar_getName(ivar);
    NSString *propertyName = [NSString stringWithCString:ivName encoding:NSUTF8StringEncoding];
    propertyName = [propertyName substringFromIndex:1];
    id value = [self valueForKey:propertyName];
    if (!value || [value isEqual:[NSNull null]])
        return nil;
    
    return @{propertyName: value};
}

+ (void)_handleIvar:(Ivar)ivar forInstance:(id)instance withResultSet:(FMResultSet *)result {
    if (ivar == NULL)
        return;
    
    if (!instance || !result)
        return;
    
    const char *ivName = ivar_getName(ivar);
    const char *ivType = ivar_getTypeEncoding(ivar);
    NSString *propertyName = [NSString stringWithCString:ivName encoding:NSUTF8StringEncoding];
    propertyName = [propertyName substringFromIndex:1];
    if (strcmp(ivType, "i") == 0 ||
        strcmp(ivType, "s") == 0 ||
        strcmp(ivType, "I") == 0 ||
        strcmp(ivType, "S") == 0) {
        SEL sel = NSSelectorFromString(@"intForColumn:");
        if (![result respondsToSelector:sel])
            return;
        
        int (*imp)(id,SEL,id) = (int(*)(id,SEL,id))class_getMethodImplementation([result class], sel);
        if (imp == NULL)
            return;
        
        int value = imp(result,sel,propertyName);
        [instance setValue:@(value) forKey:propertyName];
    }
    else if (strcmp(ivType, "d") == 0 ||
             strcmp(ivType, "f") == 0) {
        SEL sel = NSSelectorFromString(@"doubleForColumn:");
        if (![result respondsToSelector:sel])
            return;
        
        double (*imp)(id,SEL,id) = (double(*)(id,SEL,id))class_getMethodImplementation([result class], sel);
        if (imp == NULL)
            return;
        
        double value = imp(result,sel,propertyName);
        [instance setValue:@(value) forKey:propertyName];
    }
    else if (strncmp(ivType, "@", 1) == 0 ) {
        SEL sel = NSSelectorFromString(@"objectForColumn:");
        if (![result respondsToSelector:sel])
            return;
        
        id (*imp)(id,SEL,id) = (id(*)(id,SEL,id))class_getMethodImplementation([result class], sel);
        if (imp == NULL)
            return;
        
        id value = imp(result,sel,propertyName);
        [instance setValue:value forKey:propertyName];
    }
}

@end
