//
//  QQCache.h
//  xqiv
//
//  Created by smrt on 3/23/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDictionary.h"
#import "SArray.h"

namespace s {
    class Cache_t {
    public:
        Cache_t() :
            array(),
            position(0)
        {}
        void insert(Dictionary_t &dict);

        void next() {
            position = position + 1;
            if (position >= array.size()) position = 0;
        }
        
        void prev() {
            if (position == 0) {
                position = array.size() - 1;
            } else {
                position--;
            }
        }
        
        
        
        id operator[](NSString *);
        
        void update(NSMutableDictionary *);
        
        NSMutableDictionary * get();
        
        size_t size() { return array.size(); }
        
        void clear() { array.clear(); }
        
        size_t pos() { return position; }
    private:
        Array_t array;
        size_t position;
    };
}