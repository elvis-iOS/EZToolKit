
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (AES)
+ (nullable NSData *)encryptAESData:(nullable NSData *)inData enKey:(nullable NSData *)enKey;
@end

NS_ASSUME_NONNULL_END
