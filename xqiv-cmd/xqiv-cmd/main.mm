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
#include <vector>
#include <boost/program_options.hpp>

#include "repo.h"

typedef std::vector<std::string> svector_t;

NSDictionary * make_file_list(const svector_t &v) {
    NSMutableDictionary * rv = [NSMutableDictionary dictionary];

    int i = 1;
    for(svector_t::const_iterator it = v.begin(), eit = v.end();
        it != eit; ++it)
    {
        char buf[NAME_MAX];
        if (!realpath(it->c_str(), buf)) {
            std::cerr << "err: can't make real-path for file "
                      << *it << std::endl;
            continue;
        }

        [rv setObject:[NSString stringWithUTF8String:buf]
               forKey:[NSString stringWithFormat:@"%d", i]];
        i++;
    }

    return rv;
}

void send_notification(NSDictionary *dict) {
    NSDistributedNotificationCenter *notc = [NSDistributedNotificationCenter defaultCenter];
    [notc postNotificationName:@"xqiv-cmd"
                        object:nil
                      userInfo:dict
            deliverImmediately:YES];
}

int main(int argc, const char * argv[])
{
   // rep::Repository_t rep("~");
   // rep.insertFile("/etc/passwd");
    @autoreleasepool {

    NSMutableDictionary *options = [NSMutableDictionary dictionary];

    namespace po = boost::program_options;
    po::options_description desc("Allowed options");
    desc.add_options()
    ("help", "produce help message")
    ("mem", po::value<int>(), "memory limit = (100 * arg) MB")
    ("input-file", po::value< std::vector<std::string> >(), "images to show")
    ;

    po::positional_options_description p;
    p.add("input-file", -1);
    po::variables_map vm;

    po::store(po::command_line_parser(argc, argv).
              options(desc).positional(p).run(), vm);

    po::notify(vm);

    std::vector<std::string> files = vm["input-file"].as<std::vector<std::string> >();

    if (vm.count("help")) {
        std::cout << desc << "\n";
        return 1;
    }

    if (vm.count("mem")) {

        return 0;
    }
    



        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        NSDictionary* argsInfo = make_file_list(files);

        [userInfo setObject:[NSString stringWithFormat:@"%d", argc] forKey:@"argc"];
        [userInfo setObject:argsInfo forKey:@"args"];

        send_notification(userInfo);
    }

    return 0;
}