//
//  SDictionary.h
//  xqiv
//
//  Created by smrt on 3/23/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SUtils.h"

namespace s {

class Dictionary_t : s::noncopyable {
public:
    Dictionary_t();
    Dictionary_t(NSMutableDictionary *);
    ~Dictionary_t();
    
    id operator[](NSString *);
    id operator[](const char *);
    
    void remove(NSString *s);
    void remove(const char *s);

    void insert(NSString *key, id obj);
    void insert(NSString *key, Dictionary_t &dict);
    void insert(const char *key, id obj);
    void insert(const char *key, Dictionary_t &dict);

    
    NSMutableDictionary *objc() { return db; }
    
    void set(NSMutableDictionary *newDb) {
        [db release];
        db = newDb;
        [db retain];
    }
    
private:
    NSMutableDictionary *db;
};
   
    
}

