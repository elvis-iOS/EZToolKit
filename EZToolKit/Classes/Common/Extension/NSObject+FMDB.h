//
//  NSObject+FMDB.h
//  do
//
//  Created by Elvis on 2021/3/19.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (FMDB)

+ (id)fmdb_modelWithResultSet:(FMResultSet *)result;

- (NSDictionary *)fmdb_modelInfo;

@end

NS_ASSUME_NONNULL_END
