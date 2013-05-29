//
//  repo.h
//  xqiv
//
//  Created by smrt on 5/7/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef __xqiv__repo__
#define __xqiv__repo__
#include <string>
#include "sha1.h"
#include "flock.h"

#include "repo_path.h"

namespace rep {



    class Repository_t {

    public:
        Repository_t(const std::string &path);
        void init();
        void create();
        void insert(const char * data, size_t length, sha1_t checksum);
        void insert(const char * data, size_t length);
        void insert_file(std::string filename);
        const path_t & get_path() { return path; }
    private:

        std::string makeRepoPath(const std::string &path);
        path_t path;

        FLockFile_t flf;
    };
}


#endif /* defined(__xqiv__repo__) */
