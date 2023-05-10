//
//  EZSwiftyType.h
//  Pods
//
//  Created by Elvis Zhu on 2023/4/26.
//

#ifndef EZSwiftyType_h
#define EZSwiftyType_h

#if defined(__cplusplus)
#define let auto const
#else
#define let const __auto_type
#endif

#if defined(__cplusplus)
#define var auto
#else
#define var __auto_type
#endif


#define ez_defer_block_name ez_defer_ ## __LINE__
#define ez_defer __strong void(^ez_defer_block_name)(void) __attribute__((cleanup(ez_defer_cleanup_block), unused)) = ^
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static void ez_defer_cleanup_block(__strong void(^*block)(void)) {
    (*block)();
}
#pragma clang diagnostic pop


#endif /* EZSwiftyType_h */
