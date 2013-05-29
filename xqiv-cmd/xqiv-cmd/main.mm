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
#include <sys/stat.h>

#include <boost/program_options.hpp>
#include <boost/filesystem.hpp>
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


class expander_t {
public:
    expander_t(std::vector<std::string> *v) : v(v) {}
    void operator()(const std::string &file) {
        struct stat st;
        if (::stat(file.c_str(), &st) == -1) return;
        if (st.st_mode & S_IFREG) {
            v->push_back(file);
        }
    }

    std::vector<std::string> *v;
};



std::vector<std::string> expand_dirs(const std::string &aDir) {
    namespace fs = boost::filesystem;
    std::vector<std::string>  rv;
    fs::path dir(aDir);
    if (!fs::exists(dir) || !fs::is_directory(dir)) {
        rv.push_back(aDir);
        return rv;
    }
    fs::directory_iterator eit;
    for (fs::directory_iterator it(dir);
         it != eit; ++it)
    {
        std::string s = it->path().string();
        rv.push_back(s);
    }
    return rv;

}

std::vector<std::string> expand_dirs(const std::vector<std::string> &files) {
    std::vector<std::string> rv;
    expander_t e(&rv);
    std::for_each(files.begin(), files.end(), e);
    return rv;
}



int main_repo(int argc, const char **argv) {
    rep::Repository_t r("~");
    r.create();
    r.init();
    r.insert_file("/tmp/sb.txt");
    
    ///tmp/sb.txt
    return 0;
}


int main(int argc, const char **argv)
{
    return main_repo(argc, argv);
    @autoreleasepool {
        namespace po = boost::program_options;
        po::options_description desc("Allowed options");
        desc.add_options()
        ("help", "produce help message")
        //("mem", po::value<int>(), "memory limit = (100 * arg) MB")
        ("input-file", po::value< std::vector<std::string> >(), "images to show")
        ;

        po::positional_options_description p;
        p.add("input-file", -1);
        po::variables_map vm;

        po::store(po::command_line_parser(argc, argv).
                  options(desc).positional(p).run(), vm);

        po::notify(vm);

        std::vector<std::string> files;

        if (vm.count("input-file")) {
            files = vm["input-file"].as<std::vector<std::string> >();
        }

        if (files.size() == 1) {
            files = expand_dirs(files[0]);
        }

        if (vm.count("help")) {
            std::cout << desc << "\n";
            return 1;
        }

        NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        NSDictionary* argsInfo = make_file_list(files);

        [userInfo setObject:[NSString stringWithFormat:@"%zd", files.size()] forKey:@"argc"];
        [userInfo setObject:argsInfo forKey:@"args"];
        
        send_notification(userInfo);
    }
    
    return 0;
}