//
//  EZFileManager.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/27.
//

#import <Foundation/Foundation.h>

#import "EZMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface EZFileManager : NSObject

@property (nonatomic) NSString *workDir;

singletonH

// ---- 类方法为全路径 ----
+ (BOOL)createDir:(NSString *)dir;
+ (BOOL)createFile:(NSString *)file;
+ (BOOL)removeFile:(NSString *)file;
// ---- 实例方法默认加上workDir ----
- (BOOL)createDir:(NSString *)dir;
- (BOOL)createFile:(NSString *)file;
- (BOOL)removeFile:(NSString *)file;

@end

NS_ASSUME_NONNULL_END
