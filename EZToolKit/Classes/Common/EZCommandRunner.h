//
//  EZCommandRunner.h
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/25.
//

#ifndef EZCommandRunner_h
#define EZCommandRunner_h

int ez_system(const char *cmd);
int ez_runCommand(NSTimeInterval timeout, NSString **output, NSString *format, ...);
BOOL ez_killProcess(const char *processName);
int ez_pidOf(const char *processName);
// 需要签名container相关的entitlements
const char * ez_sandboxOfDaemon(const char *processName);


#endif
