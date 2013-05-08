//
//  sha1.h
//  xqiv
//
//  Created by smrt on 5/8/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef __xqiv__sha1__
#define __xqiv__sha1__

#include <string>

namespace rep {

class sha1_t {
public:
    std::string hex();
    unsigned char digest[20];
};


sha1_t sha1(const void *data, size_t len);

} // namespace rep

#endif /* defined(__xqiv__sha1__) */

