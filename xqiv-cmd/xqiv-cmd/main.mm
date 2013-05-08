//
//  main.m
//  xqiv-cmd
//
//  Created by smrt on 5/4/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <stdlib.h>
#include <iostream>
#include <sys/param.h>
#include <stdlib.h>
#include <sys/syslimits.h>

#include "repo.h"



int main(int argc, const char * argv[])
{
    rep::Repository_t rep("~");
    rep.insertFile("/etc/passwd");



    @autoreleasepool {
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        NSMutableDictionary* argsInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        
        for (int i=0; i<argc; i++) {
            char buf[NAME_MAX];
            realpath(argv[i], buf);
            [argsInfo setObject:[NSString stringWithUTF8String:buf]
                         forKey:[NSString stringWithFormat:@"%d", i]];
        }
        
        [userInfo setObject:[NSString stringWithFormat:@"%d", argc] forKey:@"argc"];
        [userInfo setObject:argsInfo forKey:@"args"];

        NSDistributedNotificationCenter *notc = [NSDistributedNotificationCenter defaultCenter];
        [notc postNotificationName:@"xqiv-cmd"
                            object:nil
                          userInfo:userInfo
                deliverImmediately:YES];
    }
    return 0;
}