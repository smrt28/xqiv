//
//  objc_helper.cpp
//  xqiv
//
//  Created by smrt on 5/7/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>

#include <openssl/sha.h>
#include <string>
#include "objc_helper.h"


namespace h {
    std::string expand_home(const std::string &path) {
        NSString *expath = [NSString stringWithUTF8String:path.c_str()];
        NSString *expanded = [expath stringByExpandingTildeInPath];
        return std::string([expanded UTF8String]);
    }



}
