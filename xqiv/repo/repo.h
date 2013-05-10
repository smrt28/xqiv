//
//  repo.h
//  xqiv
//
//  Created by smrt on 5/7/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef __xqiv__repo__
#define __xqiv__repo__
#include <string>
#include "sha1.h"
#include "flock.h"

namespace rep {
    class Metadata_t {
    public:
        std::string filename;
    };

    class Repository_t {
        class Path_t {
        public:
            Path_t(const std::string &repoPath) :
                repoPath(repoPath)
            {}
            std::string lockFile() { return repoPath + "/lock"; }
            std::string dataDir() { return repoPath + "/data"; }
            std::string tagsDir() { return repoPath + "/tags"; }
            std::string repo() { return repoPath; }
            std::string dataFileDir(sha1_t checksum) {
                std::string hex = checksum.hex();
                std::string p1 = hex.substr(0, 2);
                std::string p2 = hex.substr(2, 2);
                return dataDir() + "/" + p1 + "/" + p2;
            }

            std::string dataFile(sha1_t checksum) {
                std::string hex = checksum.hex();
                std::string p3 = hex.substr(4);
                return dataFileDir(checksum) + "/" + p3;
            }

        private:
            const std::string repoPath;
        };

    public:
        Repository_t(const std::string &path);
        void init();
        void insert(const char * data, size_t length, sha1_t checksum);
        void insertFile(std::string filename);
    private:

        std::string makeRepoPath(const std::string &path);
        Path_t path;

        FLockFile_t flf;
    };
}


#endif /* defined(__xqiv__repo__) */
