//
//  tagdb.h
//  xqiv-cmd
//
//  Created by smrt on 5/26/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef __xqiv_cmd__tagdb__
#define __xqiv_cmd__tagdb__

#include <string>
#include <vector>

#include "repo_path.h"
#include "sha1.h"
#include "error.h"


namespace rep {
class tagdb_t {
public:
    tagdb_t(const path_t &path, const std::string &tag) :
        path(path),
        tag(tag)
    {
       // read_tag_file();
    }

private:
    void read_tag_file();


    std::vector<sha1_t> db;
    const path_t &path;
    std::string tag;
};
}

#endif /* defined(__xqiv_cmd__tagdb__) */
