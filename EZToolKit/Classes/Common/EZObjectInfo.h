//
//  EZObjectInfo.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/25.
//

#ifndef EZObjectInfo_h
#define EZObjectInfo_h

#import <Foundation/Foundation.h>

// ivar
NSString * ez_ivarDescription(id obj, BOOL includeIvarValue);
void ez_getIvar(id obj, const char *ivarName, void *ivarValuePtr);
void ez_setIvar(id obj, const char *ivarName, void *ivarValue);

// property
NSString *ez_propertyDescription(id obj, BOOL includePropertyValue);

// block
NSString * ez_blockInfo(id aBlock);
NSInteger ez_blockArgCount(id aBlock);

// validation
BOOL ez_validObj(id obj);
BOOL ez_validString(NSString *obj);
BOOL ez_validDictionary(NSDictionary *obj);
BOOL ez_validArray(NSArray *obj);
BOOL ez_validData(NSData *obj);
BOOL ez_validSet(NSSet *obj);
BOOL ez_validNumber(NSNumber *obj);


#endif /* EZObjectInfo */
