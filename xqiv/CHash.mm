//
//  CHash.cpp
//  xqiv
//
//  Created by smrt on 4/7/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#include <openssl/sha.h>
#include <CommonCrypto/CommonDigest.h>

#import "CHash.h"


namespace s {
namespace hash {
    NSData * sha1(NSData *data) {
        const char *b = (const char *)[data bytes];
        CC_LONG len = (CC_LONG)[data length];
        unsigned char digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1_CTX ctx;
        CC_SHA1_Init(&ctx);
        CC_SHA1_Update(&ctx, b, len);
        CC_SHA1_Final(digest, &ctx);
        return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    }
    
    NSString * hex(NSData *data) {
        static const char *abc = "0123456789abcdef";
        
        const unsigned char *b = (const unsigned char *)[data bytes];
        size_t len = [data length];
        
        char buf[len * 2 + 1];
        
        
        char *c = buf;
        for (int i = 0; i<len; i++) {
            *c = abc[b[i] >> 4]; c++;
            *c = abc[b[i] & 0xf]; c++;
        }
        
        buf[len * 2] = 0;
        
        return [NSString stringWithUTF8String:buf];
    }
} // namespace hash
} // namespace s