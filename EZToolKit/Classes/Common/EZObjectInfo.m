//
//  EZObjectInfo.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/25.
//

#import "EZObjectInfo.h"
#import <objc/runtime.h>

#pragma mark - Ivar
void ez_getIvar(id obj, const char *ivarName, void *ivarValuePtr) {
    Ivar ivar = class_getInstanceVariable(object_getClass(obj), ivarName);
    if (ivar == NULL)
        return;
    
    ptrdiff_t offset = ivar_getOffset(ivar);
    unsigned char* bytes = (unsigned char *)(__bridge void*)obj;
    *(void **)ivarValuePtr = *((void **)(bytes+offset));
}

void ez_setIvar(id obj, const char *ivarName, void *ivarValue) {
    Ivar ivar = class_getInstanceVariable(object_getClass(obj), ivarName);
    if (ivar == NULL)
        return;
    
    ptrdiff_t offset = ivar_getOffset(ivar);
    unsigned char* bytes = (unsigned char *)(__bridge void*)obj;
    *((void **)(bytes+offset)) = ivarValue;
}

NSString * ez_ivarDescription(id obj, BOOL includeIvarValue) {
    NSMutableArray *retVal = @[].mutableCopy;
    unsigned int outCount;
    Ivar *ivList = class_copyIvarList(object_getClass(obj), &outCount);
    for (int i = 0; i < outCount; ++i) {
        Ivar iv = ivList[i];
        const char *ivName = ivar_getName(iv);
        const char *ivType = ivar_getTypeEncoding(iv);
        NSUInteger ivOffset = ivar_getOffset(iv);
        
        NSMutableString *desc = [NSMutableString stringWithFormat:@"n:%s offset:%lx t:%s", ivName, ivOffset, ivType];
        if (includeIvarValue)
            [desc appendFormat:@" value:%@", [obj valueForKey:[NSString stringWithCString:ivName encoding:NSUTF8StringEncoding]]];
        [retVal addObject:desc];
    }
    free(ivList);
    return [retVal componentsJoinedByString:@"\n"];
}

#pragma mark - property
NSString *ez_propertyDescription(id obj, BOOL includePropertyValue) {
    NSMutableArray *retVal = @[].mutableCopy;
    unsigned int outCount;
    objc_property_t *pList = class_copyPropertyList(object_getClass(obj), &outCount);
    for (int i = 0; i < outCount; ++i) {
        objc_property_t p = pList[i];
        const char *pName = property_getName(p);
        const char *pAttr = property_getAttributes(p);
        
        NSMutableString *desc = [NSMutableString stringWithFormat:@"n:%s attr:%s", pName, pAttr];
        if (includePropertyValue)
            [desc appendFormat:@" value:%@", [obj valueForKey:[NSString stringWithCString:pName encoding:NSUTF8StringEncoding]]];
        [retVal addObject:desc];
    }
    free(pList);
    return [retVal componentsJoinedByString:@"\n"];
}

#pragma mark - Block
struct BlockDescriptor {
    unsigned long reserved;
    unsigned long size;
    void *rest[1];
};

struct Block {
    void *isa;
    int flags;
    int reserved;
    void *invoke;
    struct BlockDescriptor *descriptor;
};

static const char *BlockSig(id blockObj) {
    struct Block *block = (__bridge void *)blockObj;
    struct BlockDescriptor *descriptor = block->descriptor;

    int copyDisposeFlag = 1 << 25;
    int signatureFlag = 1 << 30;

    assert(block->flags & signatureFlag);

    int index = 0;
    if(block->flags & copyDisposeFlag)
        index += 2;

    return descriptor->rest[index];
}

static void * BlockImp(id blockObj) {
    struct Block *block = (__bridge void *)blockObj;
    return block->invoke;
}

NSString * ez_blockInfo(id aBlock) {
    if (!aBlock || ![aBlock isKindOfClass:NSClassFromString(@"NSBlock")])
        return nil;
    
    const char *blockSig = BlockSig(aBlock);
    void *imp = BlockImp(aBlock);
    return  [NSString stringWithFormat:@"%@[signature:%s invoke:%lx]",aBlock,blockSig,(NSUInteger)imp];
}

NSInteger ez_blockArgCount(id aBlock) {
    if (!aBlock || ![aBlock isKindOfClass:NSClassFromString(@"NSBlock")])
        return 0;
    
    const char *blockSig = BlockSig(aBlock);
    return [[NSMethodSignature signatureWithObjCTypes:blockSig] numberOfArguments];
}


#pragma mark - validation
BOOL ez_validObj(id obj) {
    if (!obj) return NO;
    if ([obj isEqual:[NSNull null]]) return NO;
    if ([obj respondsToSelector:@selector(count)]) return [obj count] != 0;
    if ([obj respondsToSelector:@selector(length)]) return [obj length] != 0;
    
    return YES;
}

BOOL ez_validation(id obj,Class cls) {
    return ez_validObj(obj) && [obj isKindOfClass:cls];
}

BOOL ez_validString(NSString *obj) {
    return ez_validation(obj,[NSString class]);
}

BOOL ez_validDictionary(NSDictionary *obj) {
    return ez_validation(obj,[NSDictionary class]);
}

BOOL ez_validArray(NSArray *obj) {
    return ez_validation(obj,[NSArray class]);
}

BOOL ez_validData(NSData *obj) {
    return ez_validation(obj,[NSData class]);
}

BOOL ez_validSet(NSSet *obj) {
    return ez_validation(obj,[NSSet class]);
}

BOOL ez_validNumber(NSNumber *obj) {
    return ez_validation(obj,[NSNumber class]);
}

