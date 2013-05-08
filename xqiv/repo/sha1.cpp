//
//  sha1.cpp
//  xqiv
//
//  Created by smrt on 5/8/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//
#include <CommonCrypto/CommonDigest.h>

#include <openssl/sha.h>
#include "sha1.h"

namespace rep {
    sha1_t sha1(const void *data, size_t dataLen) {
        const char *b = (const char *)data;
        sha1_t rv;
        CC_LONG len = (CC_LONG)dataLen;

        CC_SHA1_CTX ctx;
        CC_SHA1_Init(&ctx);
        CC_SHA1_Update(&ctx, b, len);
        CC_SHA1_Final(rv.digest, &ctx);
        return rv;
    }

    std::string sha1_t::hex() {
        static const char *abc = "0123456789abcdef";

        const unsigned char *b = digest;
        size_t len = 20;

        char buf[len * 2 + 1];


        char *c = buf;
        for (int i = 0; i<len; i++) {
            *c = abc[b[i] >> 4]; c++;
            *c = abc[b[i] & 0xf]; c++;
        }

        buf[len * 2] = 0;
        return std::string(buf);
    }


    

}