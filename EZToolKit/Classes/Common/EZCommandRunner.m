//
//  EZCommandRunner.m
//  EZToolKit
//
//  Created by Elvis Zhu on 2023/4/25.
//

#import "EZCommandRunner.h"
#import "NSTask+EZTermination.h"
#import "EZObjectInfo.h"
#include "libproc.h"
#include <dlfcn.h>
#include <spawn.h>

int ez_system(const char *cmd) {
    static int(*ez_system)(const char *);
    if (ez_system) return ez_system(cmd);
    ez_system = dlsym(RTLD_DEFAULT, "system");
    
    return ez_system(cmd);
}

int ez_runCommand(NSTimeInterval timeout, NSString **output, NSString *format, ...) {
    va_list valist;
    va_start(valist, format);
    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:valist];
    va_end(valist);
    
    NSTimeInterval realTime = MAX(1, timeout);
    NSPipe* pipe = [NSPipe pipe];
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments:@[@"-c", formatStr]];
    [task setStandardOutput:pipe];
    [task launch];
    [task waitUntilExitWithTimeout:realTime sendTerm:YES sendKill:YES];
    
    if (output) {
        NSFileHandle* file = [pipe fileHandleForReading];
        NSData *outData = [file readDataToEndOfFile];
        if (ez_validData(outData)) {
            *output = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
        }
    }
    
    return task.terminationStatus;
}

BOOL ez_killProcess(const char *processName) {
    int pid = ez_pidOf(processName);
    if (pid == 0) return NO;
    kill(pid, SIGKILL);
    
    return YES;
}

int ez_pidOf(const char *processName) {
    int n = proc_listpids(PROC_ALL_PIDS, 0, NULL, 0);
    int *buffer = (int *)malloc(sizeof(int) * n);
    int k = proc_listpids(PROC_ALL_PIDS, 0, buffer, n * sizeof(int));
    for (int i = 0; i < k; i++) {
        int pid = buffer[i];
        if (pid == 0) continue;
        char name[2 * MAXCOMLEN];
        proc_name(pid, name, sizeof(name));
        if (strcmp(name, processName) == 0) {
            return pid;
        }
    }
    
    return 0;
}

extern const char * container_system_path_for_identifier(int zero,pid_t processId);
const char * ez_sandboxOfDaemon(const char *processName) {
    return container_system_path_for_identifier(0, ez_pidOf(processName));
}

