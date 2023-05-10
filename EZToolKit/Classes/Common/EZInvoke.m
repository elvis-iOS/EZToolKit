//
//  ezInvoke.m
//  ezLib
//
//  Created by Elvis on 2021/9/14.
//

#import "EZInvoke.h"

#import <objc/runtime.h>

BOOL ez_callWithVAList(id target, NSString *selStr, void *retValPtr, int paramCnt, va_list arg_ptr) {
    if (!target)
        return NO;
    
    SEL sel = NSSelectorFromString(selStr);
    if (![target respondsToSelector:sel])
        return NO;
    
    NSMethodSignature *sign = [target methodSignatureForSelector:sel];
    NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:sign];
    invoke.target = target;
    invoke.selector = sel;
    
    void **newIDPtr = malloc(sizeof(id *) * 100);
    void **oldIDPtr = malloc(sizeof(id *) * 100);
    int idPointerCount = 0;
    
    for(int i = 0; i < paramCnt; i++)
    {
        int argIndex = i+2;
        void *value = va_arg(arg_ptr,void *);
        const char *argType = [sign getArgumentTypeAtIndex:argIndex];
        
        if (strcmp(argType, "^@") != 0) {
            [invoke setArgument:&value atIndex:argIndex];
        }
        else {
            __strong id *idPointerValue = (__strong id *)value;
            oldIDPtr[idPointerCount] = idPointerValue;
            memcpy(newIDPtr+idPointerCount, (void*)idPointerValue, sizeof(id*));
            void *buffer = newIDPtr+idPointerCount;
            [invoke setArgument:&buffer atIndex:argIndex];

            idPointerCount += 1;
        }
    }
    
    [invoke invoke];
    
    for (int i = 0; i < idPointerCount; ++i) {
        *((__strong id*)oldIDPtr[i]) = (__bridge id)(*((void **)newIDPtr+i));
    }
    free(newIDPtr);
    free(oldIDPtr);

    if (sign.methodReturnLength > 0 && retValPtr) {
        const char *retType = sign.methodReturnType;
        if (strcmp(retType, "@") != 0) {
            [invoke getReturnValue:retValPtr];
        }
        else {
            void *tmpResult;
            [invoke getReturnValue:&tmpResult];
            __strong id *rvPtr = (__strong id *)retValPtr;
            *rvPtr = (__bridge id)tmpResult;
        }
    }

    return YES;
}

BOOL ez_callMethod(id target, NSString *selStr, void *retValPtr, int paramCnt,...) {
    va_list arg_ptr;
    va_start(arg_ptr, paramCnt);
    BOOL retVal = ez_callWithVAList(target, selStr, retValPtr, paramCnt, arg_ptr);
    va_end(arg_ptr);

    return retVal;
}

id ez_callMethodWithReturn(id target, NSString *selStr, int paramCnt,...) {
    va_list arg_ptr;
    va_start(arg_ptr, paramCnt);
    id retVal;
    ez_callWithVAList(target, selStr, &retVal, paramCnt, arg_ptr);
    va_end(arg_ptr);

    return retVal;
}

void *ez_call(NSString *methDesc, ...) {
    NSString *md = [methDesc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (md.length == 0)
        return NULL;
    
    NSMutableArray *lefts = @[].mutableCopy;
    NSMutableArray *rights = @[].mutableCopy;
    for (int i = 0; i < methDesc.length; ++i) {
        NSString *c = [methDesc substringWithRange:NSMakeRange(i, 1)];
        if ([c isEqualToString:@"["]) {
            [lefts addObject:@(i)];
        }
        else if ([c isEqualToString:@"]"]) {
            [rights addObject:@(i)];
        }
    }
    if (lefts.count == 0 ||
        lefts.count != rights.count)
        return NULL;
    
    NSLog(@"-->> lefts:%@ rights:%@", lefts, rights);
    NSUInteger loc = [[lefts lastObject] unsignedIntegerValue] + 1;
    [lefts removeLastObject];
    NSUInteger len = [[rights firstObject] unsignedIntegerValue] - loc;
    [rights removeObjectAtIndex:0];
    
    NSString *methStr = [methDesc substringWithRange:NSMakeRange(loc, len)];
    NSLog(@"-->> methStr:%@", methStr);
    
    return NULL;
}


/**
 测试案例:
 - (void (^)(void))test11:(NSString **)arg1 :(NSArray **)arg2 :(NSDictionary **)arg3 :(NSError **)arg4 {
     
     *arg1 = @"aaa";
     *arg2 = @[@"1",@[@(2)]];
     *arg3 = @{@"c":@"d"};
     *arg4 = [NSError errorWithDomain:NSURLErrorDomain code:-43 userInfo:nil];
     
     return ^{
         NSLog(@"done");
     };
 }
 
 使用方法:
 
 NSString *str;
 NSArray *arr;
 NSDictionary *dic;
 NSError *err;
 void (^block)(void);
 
 ez_callMethod(self, @selector(test11::::), &block, 4,&str,&arr,&dic,&err);
 
 NSLog(@"str:%@ arr:%@ dic:%@ err:%@",str,arr,dic,err);
 block();
 
 */
