//
//  error.h
//  xqiv-cmd
//
//  Created by smrt on 5/8/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef __xqiv_cmd__error__
#define __xqiv_cmd__error__
#include <string>
namespace rep {
    class Error_t {
    public:
        enum Code_t {
            UNKNOWN = 0,
            OPEN,
            FLOCK
        };
        Error_t(Code_t c, const std::string &msg) :
            _message(msg),
            _code(c)
        {}

        Error_t(const std::string &msg) :
            _message(msg),
            _code(UNKNOWN)
        {}

        std::string message() { return _message; }
        Code_t code() { return _code; }

    private:
        std::string _message;
        Code_t _code;

    };
}

#endif /* defined(__xqiv_cmd__error__) */
