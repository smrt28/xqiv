//
//  repo.cpp
//  xqiv
//
//  Created by smrt on 5/7/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#include <boost/filesystem.hpp>
#include <iostream>   
#include <fstream>

#include "objc_helper.h"
#include "repo.h"
#include "error.h"


namespace rep {
    class Buffer_t {
    public:
        Buffer_t(size_t size) : size(size) {
            data = new char [size];
        }
        ~Buffer_t() {
            delete data;
        }
        char *data;
        size_t size;
    };

    Repository_t::Repository_t(const std::string &path) :
        path(makeRepoPath(path))
    {
        init();
    }

    void Repository_t::init() {
        boost::filesystem::create_directory(path.repo());
        boost::filesystem::create_directory(path.tagsDir());
        std::ofstream lf(path.lockFile().c_str());
        if (!lf) {
            throw Error_t(Error_t::OPEN, "can't create lock file");
        }
        lf.close();
        flf.open(path.lockFile());
    }

    std::string Repository_t::makeRepoPath(const std::string &path) {
        return h::expand_home(path + "/.xqivrepo");
    }

    void Repository_t::insert(const char * data, size_t length, sha1_t checksum) {
        FLock_t lock(flf);

        if (boost::filesystem::exists(path.dataFile(checksum))) {
            return;
        }

        boost::filesystem::create_directories(path.dataFileDir(checksum));
        std::ofstream outfile (path.dataFile(checksum).c_str(),
                               std::ofstream::binary);
        outfile.write(data, length);
    }

    void Repository_t::insertFile(std::string filename) {
        std::ifstream is(filename.c_str(), std::ifstream::binary);
        if (!is) return;

        is.seekg (0, is.end);
        size_t length = is.tellg();
        is.seekg (0, is.beg);

        // 50MB limit
        if (length > 52428800) return;

        Buffer_t buffer(length);

        is.read(buffer.data,length);
        if (!is) return;

        sha1_t sha = sha1(buffer.data, length);
        insert(buffer.data, buffer.size, sha);
    }

}