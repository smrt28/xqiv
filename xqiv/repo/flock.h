//
//  flock.h
//  xqiv-cmd
//
//  Created by smrt on 5/8/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef __xqiv_cmd__flock__
#define __xqiv_cmd__flock__

#include <string>

namespace rep {
class FLockFile_t {
public:
    FLockFile_t(const std::string &file);
    FLockFile_t() : fd(-1) {}
    ~FLockFile_t();

    void open(const std::string &file);
    void lock();
    void unlock();
private:
    int fd;
    bool locked;

};

template<typename XLock_t>
class Lock_t {
public:
    Lock_t(XLock_t &l) : lock(&l)
    { lock->lock(); }

    void unlock() {
        if (!lock) return;
        lock->unlock();
        lock = 0;
    }

    ~Lock_t() {
        if (lock)
            lock->unlock();
    }

private:
    XLock_t *lock;
};

typedef Lock_t<FLockFile_t> FLock_t;

}

#endif /* defined(__xqiv_cmd__flock__) */
