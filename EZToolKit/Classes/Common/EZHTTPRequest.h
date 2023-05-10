//
//  EZHTTPRequest.h
//  EZlib
//
//  Created by Elvis on 2021/9/7.
//

#import <Foundation/Foundation.h>
#import "EZMacros.h"

NS_ASSUME_NONNULL_BEGIN

OBJC_EXTERN NSString *EZRecordKey_req_url;
OBJC_EXTERN NSString *EZRecordKey_req_header;
OBJC_EXTERN NSString *EZRecordKey_req_time;
OBJC_EXTERN NSString *EZRecordKey_req_content;
OBJC_EXTERN NSString *EZRecordKey_resp_header;
OBJC_EXTERN NSString *EZRecordKey_resp_content;
OBJC_EXTERN NSString *EZRecordKey_resp_time;
OBJC_EXTERN NSString *EZRecordKey_redirects;

typedef void (^EZHTTPRequestCompBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

typedef NS_ENUM(NSUInteger, EZHTTPRequestMethod) {
    EZHTTPRequestMethodGet,
    EZHTTPRequestMethodPost
};

@interface EZHTTPRequest : NSObject

// default is 30 seconds
@property (nonatomic) NSTimeInterval timeoutForRequest;

// default is IgnoringLocalCacheData
@property (nonatomic) NSURLRequestCachePolicy cachePolicy;

@property (nonatomic) NSMutableDictionary<NSString *, NSMutableDictionary *> *recordedRequest;

singletonH

- (NSString *)requestWithURLString:(NSString *)URLString method:(EZHTTPRequestMethod)method params:(nullable id)params headers:(nullable NSDictionary *)headers retryCount:(NSUInteger)retryCount timeout:(NSTimeInterval)timeout recordRequest:(BOOL)shouldRecord completion:(EZHTTPRequestCompBlock)compBlock;


- (void)requestWithURLString:(NSString *)URLString method:(EZHTTPRequestMethod)method params:(nullable id)params headers:(nullable NSDictionary *)headers retryCount:(NSUInteger)retryCount completion:(EZHTTPRequestCompBlock)compBlock;
- (void)requestWithURLString:(NSString *)URLString method:(EZHTTPRequestMethod)method params:(nullable id)params headers:(nullable NSDictionary *)headers retryCount:(NSUInteger)retryCount timeout:(NSTimeInterval)timeout completion:(EZHTTPRequestCompBlock)compBlock;

- (void)postRequestWithURLString:(NSString *)URLString params:(nullable id)params completion:(nullable EZHTTPRequestCompBlock)compBlock;
- (void)getRequestWithURLString:(NSString *)URLString params:(nullable NSDictionary *)params completion:(nullable EZHTTPRequestCompBlock)compBlock;

// 表单数据提交
- (void)postFormDataWithURLString:(NSString *)URLString params:(nullable id)params headers:(nullable NSDictionary *)headers completion:(nullable EZHTTPRequestCompBlock)compBlock;

- (void)clearMemory;

- (NSDictionary *)popRecordedRequestForID:(NSString *)reqID;

@end

NS_ASSUME_NONNULL_END
