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

namespace rep {

    class Repository_t {
        class LockFile_t {
        public:
            LockFile_t(std::string lockFile);
            int fd;
        };
    public:
        Repository_t(const std::string &path);
        void init();
        void insert(const char * data, size_t length, sha1_t checksum);
        void insertFile(std::string filename);
    private:
        std::string makeLockPath();

        std::string makeRepoPath(const std::string &path);
        const std::string repoPtah;

        FLockFile_t flf;
    };
}


#endif /* defined(__xqiv__repo__) */
