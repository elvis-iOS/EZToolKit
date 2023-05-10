//
//  EZInvoke.h
//  EZToolKit
//
//  Created by Elvis on 2021/9/14.
//

#ifndef EZInvoke_h
#define EZInvoke_h

#import <Foundation/Foundation.h>

 BOOL ez_callWithVAList(id target, NSString *selStr, void *retValPtr, int paramCnt, va_list arg_ptr);
 BOOL ez_callMethod(id target, NSString *selStr, void *retValPtr, int paramCnt,...);
 id ez_callMethodWithReturn(id target, NSString *selStr, int paramCnt,...);

void *ez_call(NSString *methDesc, ...);

#endif /* EZInvoke */
