//
//  NSTask+EZTermination.m
//  Pods
//
//  Created by gavinYang on 2022/7/14.
//

#import "NSTask+EZTermination.h"

#include <signal.h>

@implementation NSTask (EZTermination)

- (BOOL)waitUntilExitWithTimeout:(CFTimeInterval)to sendTerm:(BOOL)sendterm sendKill:(BOOL)sendkill {
    CFAbsoluteTime      started;
    CFAbsoluteTime      passed;
    BOOL                exited = NO;

    started = CFAbsoluteTimeGetCurrent();
    for (CFAbsoluteTime now = started; !exited && ((passed = now - started) < to); now = CFAbsoluteTimeGetCurrent()) {
        if (![self isRunning]) {
            exited = YES;
        }
        else {
            CFAbsoluteTime sleepTime = 0.1;
            useconds_t sleepUsec = round(sleepTime * 1000000.0);
            if (sleepUsec == 0) sleepUsec = 1;
            usleep(sleepUsec); // sleep for 0.1 sec
        }
    }

    if (!exited) {
        if (sendterm) {
            to = 2; // 2 second timeout, waiting for SIGTERM to kill process
            [self terminate];
            /* // UNIX way
             pid_t pid = [self processIdentifier];
             kill(pid, SIGTERM);
             */
            started = CFAbsoluteTimeGetCurrent();
            for (CFAbsoluteTime now = started; !exited && ((passed = now - started) < to); now = CFAbsoluteTimeGetCurrent()) {
                if (![self isRunning]) {
                    exited = YES;
                }
                else {
                    usleep(100000);
                }
            }
        }

        if (!exited && sendkill) {
            to = 2; // 2 second timeout, waiting for SIGKILL to kill process
            //NSLog(@"%@ sending SIGKILL", self);
            pid_t pid = [self processIdentifier];
            kill(pid, SIGKILL);

            started = CFAbsoluteTimeGetCurrent();
            for (CFAbsoluteTime now = started; !exited && ((passed = now - started) < to); now = CFAbsoluteTimeGetCurrent()) {
                if (![self isRunning]) {
                    exited = YES;
                }
                else {
                    usleep(100000); // sleep for 0.1 sec
                }
            }
        }
    }

    return exited;
}

@end
