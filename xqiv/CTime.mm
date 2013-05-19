//
//  CTime.cpp
//  xqiv
//
//  Created by smrt on 5/14/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#include <sys/time.h>

#include "CTime.h"


namespace s {
    namespace time {
        int64_t now() {

            struct timeval tv;
            if (gettimeofday(&tv, NULL) == -1) {
                NSLog(@"gettimeofday failed");
                return 0;
            }
            return static_cast<int64_t>(tv.tv_sec) * 1000 +
                   static_cast<int64_t>(tv.tv_usec);
        }
    }
}