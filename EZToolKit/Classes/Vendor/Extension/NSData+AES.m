
#import "NSData+AES.h"
#import <zlib.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (AES)
#pragma mark - AES
+ (NSData *)encryptAESData:(NSData *)inData enKey:(NSData *)enKey {
    //判断解密的流数据是否存在
    if ((inData == nil) || (inData == NULL)) {
        return nil;
    } else if (![inData isKindOfClass:[NSData class]]) {
        return nil;
    } else if ([inData length] <= 0) {
        return nil;
    }
    
    //判断解密的Key是否存在
    if ((enKey == nil) || (enKey == NULL)) {
        return nil;
    } else if (![enKey isKindOfClass:[NSData class]]) {
        return nil;
    } else if ([enKey length] <= 0) {
        return nil;
    }
    
    //setup key
    NSData *result = nil;
    unsigned char cKey[kCCKeySizeAES128];
    bzero(cKey, sizeof(cKey));
    [enKey getBytes:cKey length:kCCKeySizeAES128];
    
    //setup output buffer
    size_t bufferSize = [inData length] + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    //do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionECBMode|kCCOptionPKCS7Padding,
                                          cKey,
                                          kCCKeySizeAES128,
                                          nil,
                                          [inData bytes],
                                          [inData length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if (cryptStatus == kCCSuccess) {
        result = [NSData dataWithBytesNoCopy:buffer length:encryptedSize];
    } else {
        free(buffer);
    }
    return result;
}
@end
