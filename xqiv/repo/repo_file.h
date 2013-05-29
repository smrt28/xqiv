
#ifndef __xqiv_cmd__repo_file__
#define __xqiv_cmd__repo_file__

#include "repo_path.h"
namespace  rep {

class file_t {
public:
    file_t(path_t &path) :
        path(path)
    {}

    void copy(const std::string &filename);
    
private:
    path_t &path;
};

} // namespace rep


#endif /* defined(__xqiv_cmd__repo_file__) */
