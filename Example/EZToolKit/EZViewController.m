//
//  EZViewController.m
//  EZToolKit
//
//  Created by zhujun on 04/17/2023.
//  Copyright (c) 2023 zhujun. All rights reserved.
//

#import "EZViewController.h"

@import EZToolKit;

@interface EZViewController ()

@end

@implementation EZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    NSString *logDir = [[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] path];
//    [[EZLogger shared] setFileLogger:[EZFileLogger fileLoggerWithLevel:EZLogLevelInfo logDir:logDir maxSize:1024 maxAge:60*60*24*30]];
//
//    ez_setLogPrefix(@"[EZToolKit] -->>");
//    ez_setLogLevel(EZLogLevelTrace);
//    EZLogTrace(@"%@", [[EZLogger shared] fileLogger].currentLogFilePath);
//    EZLogTrace(@"trace");
//    EZLogDebug(@"debug");
//    EZLogInfo(@"info");
//    EZLogWarn(@"warn");
//    EZLogError(@"error");
//    EZLogFatal(@"fatal");
//
//    [EZAppManager queryStoreAppInfoForItem:@(389801252) country:@"us" completion:^(EZAppInfo * _Nullable appInfo) {
//        EZLogInfo(@"%@", [appInfo yy_modelToJSONString]);
//    }];
    NSString *whitelist = @"Library/Caches";
    NSMutableArray *array = @[].mutableCopy;
    [[whitelist pathComponents] ez_reduce:@"" combine:^id (NSString *accumulator, NSString *value) {
        NSString *retVal = [accumulator stringByAppendingPathComponent:value];
        [array addObject:retVal];
        return retVal;
    }];
    EZLogInfo(@"%@", array);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ez_callMethod([EZLogger shared], @"_logFilePath", NULL, 0);
}

@end
