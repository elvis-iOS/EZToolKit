//
//  EZMacros.h
//  Pods
//
//  Created by Elvis Zhu on 2023/4/26.
//

#ifndef EZMacros_h
#define EZMacros_h

/* ------------  单例  ------------ */

#define singletonH      + (instancetype)shared;

#define singletonM(ClassName)                                       \
+ (instancetype)shared {                                            \
    static ClassName *_instance;                                    \
    static dispatch_once_t onceToken;                               \
    dispatch_once(&onceToken, ^{                                    \
        _instance = [[ClassName alloc] init];                       \
    });                                                             \
    return _instance;                                               \
}

/* ------------  guard  ------------ */
#define ez_guard(condition) if ((condition) == NO)
#define ez_guardReturn(condition) if ((condition) == NO) {return;}
#define ez_guardReturnValue(condition, value) if ((condition) == NO) {return value;}

#endif /* EZMacros_h */
