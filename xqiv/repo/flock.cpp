//
//  flock.cpp
//  xqiv-cmd
//
//  Created by smrt on 5/8/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#include <fcntl.h>
#include <sys/file.h>

#include "flock.h"
#include "error.h"

namespace rep {
    FLockFile_t::FLockFile_t(const std::string &file) {
        this->open(file);
    }

    FLockFile_t::~FLockFile_t() {
        ::close(fd);
    }

    void FLockFile_t::lock() {
        if (::flock(fd, LOCK_EX) == -1) {
            throw Error_t(Error_t::FLOCK, "flock(fd, LOCK_EX) failed");
        }
    }

    void FLockFile_t::unlock() {
        if (::flock(fd, LOCK_UN) == -1) {
            throw Error_t(Error_t::FLOCK, "flock(fd, LOCK_UN) failed");
        }
    }

    void FLockFile_t::open(const std::string &file) {
        fd = ::open(file.c_str(), O_RDONLY);
        if (fd == -1) {
            throw Error_t(Error_t::OPEN, "can't open lock file");
        }
    }
}