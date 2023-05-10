//
//  EZHTTPRequest.m
//  EZlib
//
//  Created by Elvis on 2021/9/7.
//

#import "EZHTTPRequest.h"
#import "EZObjectInfo.h"
#import "EZLogger.h"
#import "EZUtil.h"

#import <objc/runtime.h>

NSString *EZRecordKey_req_url = @"req_url";
NSString *EZRecordKey_req_header = @"req_header";
NSString *EZRecordKey_req_time = @"req_time";
NSString *EZRecordKey_req_content = @"req_content";
NSString *EZRecordKey_resp_header = @"resp_header";
NSString *EZRecordKey_resp_content = @"resp_content";
NSString *EZRecordKey_resp_time = @"resp_time";
NSString *EZRecordKey_redirects = @"redirects";

@interface EZHTTPRequest ()<NSURLSessionDelegate> {
    
    BOOL _userSettedCachePolicy;
}

@property (nonatomic) NSURLSession *requestSession;
@property (nonatomic) dispatch_queue_t responseQueue;
@property (nonatomic) NSMutableDictionary<NSString *,EZHTTPRequestCompBlock> *cachedBlockInfo;


@end



@implementation EZHTTPRequest

@synthesize timeoutForRequest = _timeoutForRequest;
@synthesize cachePolicy = _cachePolicy;

singletonM(EZHTTPRequest)

- (NSString *)requestWithURLString:(NSString *)URLString
                            method:(EZHTTPRequestMethod)method
                            params:(id)params
                           headers:(NSDictionary *)headers
                        retryCount:(NSUInteger)retryCount
                           timeout:(NSTimeInterval)timeout
                     recordRequest:(BOOL)shouldRecord
                        completion:(EZHTTPRequestCompBlock)compBlock
{
    NSString *UUIDString = [[NSUUID UUID] UUIDString];
    [self.cachedBlockInfo setValue:compBlock forKey:UUIDString];
    
    if (!ez_validString(URLString)) {
        [self _completeWithError:[EZHTTPRequest _HTTPErrorWithUnderlyingError:nil infoFormat:@"invalid URL string"] forIdentifier:UUIDString];
        return UUIDString;
    }
    
    NSString *realMethod = [EZHTTPRequest _methodName:method];
    if (!ez_validString(realMethod)) {
        [self _completeWithError:[EZHTTPRequest _HTTPErrorWithUnderlyingError:nil infoFormat:@"Invalid HTTP method: %lu", method] forIdentifier:UUIDString];
        return UUIDString;
    }
    
    NSError *error;
    NSMutableURLRequest *request = nil;
    if (method == EZHTTPRequestMethodGet)
        request = [self _generateGetRequest:URLString withParams:params error:&error];
    
    else
        request = [self _generatePostRequest:URLString withParams:params error:&error];
    
    if (error) {
        [self _completeWithError:error forIdentifier:UUIDString];
        return UUIDString;
    }

    if (timeout > 0) {
        [request setTimeoutInterval:timeout];
    }
    
    [request setHTTPMethod:realMethod];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (ez_validDictionary(headers)) {
        for (NSString *key in headers) {
            [request setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    if (shouldRecord) {
        NSMutableDictionary *requestInfo = @{
            EZRecordKey_req_url: ez_safeString(request.URL.absoluteString),
            EZRecordKey_req_content: params ? ez_safeString(ez_JSONStringFromObj(params)) : @"",
            EZRecordKey_req_header: ez_validDictionary(request.allHTTPHeaderFields) ? ez_safeString(ez_JSONStringFromObj(request.allHTTPHeaderFields)) : @"",
            EZRecordKey_req_time: @([[NSDate date] timeIntervalSince1970]),
        }.mutableCopy;
        [self.recordedRequest setValue:requestInfo forKey:UUIDString];
    }

    NSURLSessionTask *task = [self.requestSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpResp.statusCode;
        
        if (error || statusCode >= 400) {
            
            if (retryCount) {
                NSUInteger newRC = retryCount - 1;
                [self.cachedBlockInfo removeObjectForKey:UUIDString];
                [self requestWithURLString:URLString method:method params:params headers:headers retryCount:newRC completion:compBlock];
                return;
            }
            
            [self _completeWithError:error forIdentifier:UUIDString];
            return;
        }
        
        if (shouldRecord) {
            NSMutableDictionary *existedInfo = [self.recordedRequest valueForKey:UUIDString];
            [existedInfo setValue:ez_safeString(ez_JSONStringFromObj([httpResp allHeaderFields])) forKey:EZRecordKey_resp_header];
            [existedInfo setValue:@([[NSDate date] timeIntervalSince1970]) forKey:EZRecordKey_resp_time];
            
            id obj = ez_JSONObjectWithData(data);
            NSString *objStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (obj)
                [existedInfo setValue:ez_safeString(ez_JSONStringFromObj(obj)) forKey:EZRecordKey_resp_content];
            else if (ez_validString(objStr))
                [existedInfo setValue:objStr forKey:EZRecordKey_resp_content];
            else
                [existedInfo setValue:@"" forKey:EZRecordKey_resp_content];
        }
        
        [self _completeWithData:data
                       response:response
                          error:error
                     identifier:UUIDString];
        
    }];
    [self _addIdentifier:UUIDString forTask:task];
    [task resume];
    
    return UUIDString;
}

- (void)requestWithURLString:(NSString *)URLString
                      method:(EZHTTPRequestMethod)method
                      params:(id)params
                     headers:(nullable NSDictionary *)headers
                  retryCount:(NSUInteger)retryCount
                  completion:(EZHTTPRequestCompBlock)compBlock
{
    [self requestWithURLString:URLString method:method params:params headers:headers retryCount:retryCount timeout:0 completion:compBlock];
}

- (void)requestWithURLString:(NSString *)URLString
                      method:(EZHTTPRequestMethod)method
                      params:(id)params
                     headers:(nullable NSDictionary *)headers
                  retryCount:(NSUInteger)retryCount
                     timeout:(NSTimeInterval)timeout
                  completion:(EZHTTPRequestCompBlock)compBlock
{
    [self requestWithURLString:URLString method:method params:params headers:headers retryCount:retryCount timeout:timeout recordRequest:NO completion:compBlock];
}

- (void)postRequestWithURLString:(NSString *)URLString
                          params:(id)params
                      completion:(EZHTTPRequestCompBlock)compBlock
{
    [self requestWithURLString:URLString method:EZHTTPRequestMethodPost params:params headers:nil retryCount:0 completion:compBlock];
}

- (void)getRequestWithURLString:(NSString *)URLString
                         params:(NSDictionary *)params
                     completion:(EZHTTPRequestCompBlock)compBlock
{
    [self requestWithURLString:URLString method:EZHTTPRequestMethodGet params:params headers:nil retryCount:0 completion:compBlock];
}

- (void)postFormDataWithURLString:(NSString *)URLString params:(id)params headers:(NSDictionary *)headers completion:(EZHTTPRequestCompBlock)compBlock {
    
    //WARNING: unfinished
//    static NSString *FORMDATA_BOUNDARY = @"ez_FORMDATA_BOUNDARY";
////    _compBlock = compBlock;
//
//    NSURL *URL = [NSURL URLWithString:URLString];
//    if (!URL) {
//        [self _executeCompBlockWithError:[EZHTTPRequest _HTTPErrorWithUnderlyingError:nil infoFormat:@"failed to init URL with string: %@", URLString]];
//        return;
//    }
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
//    [request setHTTPMethod:@"POST"];
//
//    NSData *HTTPBody = [self _bodyForParams:params withBoundary:FORMDATA_BOUNDARY];
//    [request setHTTPBody:HTTPBody];
//
//    [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
//        [request setValue:obj forHTTPHeaderField:key];
//    }];
//
//    NSString *content = [[NSString alloc] initWithFormat:@"multipart/form-data; boundary=%@", FORMDATA_BOUNDARY];
//    [request setValue:content forHTTPHeaderField:@"Content-Type"];
//    [request setValue:[NSString stringWithFormat:@"%lu", [HTTPBody length]] forHTTPHeaderField:@"Content-Length"];
}

- (void)clearMemory {
    [self.requestSession finishTasksAndInvalidate];
    _requestSession = nil;
}

- (NSDictionary *)popRecordedRequestForID:(NSString *)reqID {
    if (!ez_validString(reqID))
        return nil;
    
    NSMutableDictionary *retVal = [self.recordedRequest valueForKey:reqID];
    [self.recordedRequest removeObjectForKey:reqID];
    return retVal.copy;
}

#pragma mark - Private class method

+ (NSString *)_methodName:(EZHTTPRequestMethod)method {
    NSString *result = nil;
    
    switch (method) {
        case EZHTTPRequestMethodGet:
            result = @"GET";
            break;
        case EZHTTPRequestMethodPost:
            result = @"POST";
            break;
            
        default:
            result = nil;
            break;
    }
    
    return result;
}

+ (NSError *)_HTTPErrorWithUnderlyingError:(NSError *)error infoFormat:(NSString *)format,... {
    va_list valist;
    va_start(valist, format);
    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:valist];
    va_end(valist);
    
    return ez_error(@"EZHTTPRequestErrorDomain", -1, error, formatStr);
}

#pragma mark - Generate request

- (NSMutableURLRequest *)_generateGetRequest:(NSString *)URLString withParams:(NSDictionary *)params error:(NSError **)error {
    NSURL *URL = [NSURL URLWithString:URLString];
    if (!URL) {
        *error = [EZHTTPRequest _HTTPErrorWithUnderlyingError:nil infoFormat:@"failed to init URL with string: %@", URLString];
        return nil;
    }
    
    if (!ez_validDictionary(params))
        return [NSMutableURLRequest requestWithURL:URL];
    
    NSMutableString *tmpURLStr = URLString.mutableCopy;
    NSUInteger index = 0;
    for (NSString *key in params) {
        
        NSString *prefix = index == 0 ? @"?" : @"&";
        NSString *v = params[key];
        if ([v isKindOfClass:[NSString class]])
            v = [v stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *URLComps = [NSString stringWithFormat:@"%@%@=%@",prefix,key,v];
        [tmpURLStr appendString:URLComps];
        
        index += 1;
    }

    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tmpURLStr.copy]];
}

- (NSMutableURLRequest *)_generatePostRequest:(NSString *)URLString withParams:(id)params error:(NSError **)error {
    NSURL *URL = [NSURL URLWithString:URLString];
    if (!URL) {
        *error = [EZHTTPRequest _HTTPErrorWithUnderlyingError:nil infoFormat:@"failed to init URL with string: %@", URLString];
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    if (!ez_validDictionary(params) && !ez_validData(params))
        return request;
    
    NSData *HTTPBody;
    if (ez_validData(params)) {
        HTTPBody = params;
    }
    else {
        NSError *JSONErr;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&JSONErr];
        if (JSONErr || !ez_validData(JSONData)) {
            *error = [EZHTTPRequest _HTTPErrorWithUnderlyingError:JSONErr infoFormat:@"failed to serialization JSONObj: %@", params];
            return nil;
        }
        HTTPBody = JSONData;
    }
    
    [request setHTTPBody:HTTPBody];
    return request;
}

- (void)_addIdentifier:(NSString *)UUIDString forTask:(NSURLSessionTask *)task {
    objc_setAssociatedObject(task, "com.elvis.EZ.requestIdentifier", UUIDString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)_identifierForTask:(NSURLSessionTask *)task {
    NSString *retVal = objc_getAssociatedObject(task, "com.elvis.EZ.requestIdentifier");
    return retVal ? retVal : @"";
}

#pragma mark - Completion
- (void)_completeWithError:(NSError *)err forIdentifier:(NSString *)UUIDString {
    [self _completeWithData:nil response:nil error:err identifier:UUIDString];
}

- (void)_completeWithData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error identifier:(NSString *)UUIDString {
    EZHTTPRequestCompBlock compBlock = [self.cachedBlockInfo valueForKey:UUIDString];
    if (!compBlock)
        return;
    
    dispatch_async(self.responseQueue, ^{
        compBlock(data, response, error);
    });
    [self.cachedBlockInfo removeObjectForKey:UUIDString];
}

#pragma mark - delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    EZLogTrace(@"willPerformHTTPRedirection urlResponse %@", response.URL.absoluteString);
    NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
    NSDictionary *dic = urlResponse.allHeaderFields;
    NSString *location = dic[@"Location"];
    
    BOOL shouldRedirect = [location hasPrefix:@"http://"] || [location hasPrefix:@"https://"];
    if (!shouldRedirect) {
        EZLogTrace(@"finish redirect");
        completionHandler(nil);
        return;
    }
    
    NSString *UUIDString = [self _identifierForTask:task];
    NSMutableDictionary *existedInfo = [self.recordedRequest valueForKey:UUIDString];
    if (!existedInfo) {
        completionHandler(request);
        return;
    }
    
    NSMutableArray *redirects = existedInfo[EZRecordKey_redirects];
    if (!ez_validArray(redirects)) {
        redirects = @[].mutableCopy;
        [existedInfo setValue:redirects forKey:EZRecordKey_redirects];
    }
    
    [redirects addObject:[response description]];
    completionHandler(request);
}

#pragma mark - Property
- (NSURLSession *)requestSession {
    if (_requestSession)
        return _requestSession;
    
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setMemoryCapacity:0];
    [cache setDiskCapacity:0];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = self.timeoutForRequest;
    configuration.requestCachePolicy = self.cachePolicy;
    _requestSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
    return _requestSession;
}

- (void)setTimeoutForRequest:(NSTimeInterval)timeoutForRequest {
    if (timeoutForRequest <= 0)
        return;

    _timeoutForRequest = timeoutForRequest;
}

- (NSTimeInterval)timeoutForRequest {
    if (_timeoutForRequest == 0)
        _timeoutForRequest = 30;
    
    return _timeoutForRequest;
}

- (void)setCachePolicy:(NSURLRequestCachePolicy)cachePolicy {
    if (cachePolicy < 0 || cachePolicy > 5)
        return;
    
    _userSettedCachePolicy = YES;
    _cachePolicy = cachePolicy;
}

- (NSURLRequestCachePolicy)cachePolicy {
    if (!_userSettedCachePolicy)
        return NSURLRequestReloadIgnoringLocalCacheData;
    
    return _cachePolicy;
}

- (dispatch_queue_t)responseQueue {
    if (_responseQueue)
        return _responseQueue;
    
    _responseQueue = dispatch_queue_create("com.elvis.EZ.HTTPResponseQueue", DISPATCH_QUEUE_CONCURRENT);
    return _responseQueue;
}

- (NSMutableDictionary<NSString *,EZHTTPRequestCompBlock> *)cachedBlockInfo {
    if (_cachedBlockInfo)
        return _cachedBlockInfo;
    
    _cachedBlockInfo = @{}.mutableCopy;
    return _cachedBlockInfo;
}

- (NSMutableDictionary<NSString *,NSMutableDictionary *> *)recordedRequest {
    if (_recordedRequest)
        return _recordedRequest;
    
    _recordedRequest = @{}.mutableCopy;
    return _recordedRequest;
}


@end
