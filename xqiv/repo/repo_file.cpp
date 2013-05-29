//
//  repo_file.cpp
//  xqiv-cmd
//
//  Created by smrt on 5/24/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//
#include <stdio.h>
#include "repo_file.h"
namespace rep {

void file_t::copy(const std::string &filename) {
    char buf[L_tmpnam];
    tmpnam(buf);
    
    std::string tmpFile = path.temp_dir() + "/" + buf;
}

}