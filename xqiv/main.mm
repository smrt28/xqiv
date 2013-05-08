//
//  main.m
//  xqiv
//
//  Created by smrt on 3/16/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <unistd.h>
#include <iostream>
#include <signal.h>
#import "ns-array.h"
#import "ns-dict.h"

int cmd_main(int argc, char *argv[]) {
    return 0;
}

int main(int argc, char *argv[])
{/*
    @autoreleasepool {
        NSWorkspace *ws = [NSWorkspace sharedWorkspace];
        NSArray *apps = [ws runningApplications];
        int i = 0;
        NSRunningApplication *xqiv = [NSRunningApplication currentApplication];

        NSString *project_id = @"cz.smrt28.xqiv";

        for (NSRunningApplication  *app in apps) {
            NSString *appId = [app bundleIdentifier];
            if ([project_id isEqualToString:appId]) {
                return cmd_main(argc, argv);
            }
        }
    }

    
    if (fork() == 0) {
        [NSBundle loadNibNamed:@"MainMenu" owner:NSApp];
        [NSApp run];
    } else {
        sleep(10);
        return 0;
    }




    //[NSApplication sharedApplication];
    [NSBundle loadNibNamed:@"MainMenu" owner:NSApp];
    [NSApp run];
*/

    return NSApplicationMain(argc, (const char **)argv);

}
