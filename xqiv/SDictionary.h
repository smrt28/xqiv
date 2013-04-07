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
    template<typename Val_t>
    inline id create(Val_t value) {
        return value;
    }
    
    template<>
    inline id create<>(int value) {
        return  [NSNumber numberWithInt:value];
    }
    
    
    template<typename Val_t>
    inline Val_t value(id obj);
    
    template<>
    inline int value<>(id obj) {
        NSNumber *n = obj;
        return [n intValue];
    }
    

    
class Dictionary_t : s::noncopyable {
public:
    Dictionary_t();
    Dictionary_t(NSMutableDictionary *);
    Dictionary_t(const Dictionary_t &dict) {
        db = dict.db;
        [db retain];
    }
    
    Dictionary_t & operator=(Dictionary_t &dict) {
        set(dict.db);
        return *this;
    }
    
    ~Dictionary_t();
    
    id operator[](NSString *);
    id operator[](const char *);
    
    void remove(NSString *s);
    void remove(const char *s);

    void insert(NSString *key, id obj);
    void insert(NSString *key, Dictionary_t &dict);
    void insert(const char *key, id obj);
    void insert(const char *key, Dictionary_t &dict);
    
    template<typename objc_t, typename key_t>
    objc_t * objc(key_t *key) {
        return ((*this)[key]);
    }
    
    template<typename Val_t>
    Val_t value(NSString *key) {
        return s::value<Val_t>((*this)[key]);
    }
    
    NSMutableDictionary *objc() { return db; }
    
    void set(NSMutableDictionary *newDb) {
        if (newDb == db) return;
        [db release];
        db = newDb;
        [db retain];
    }
    
    template<typename Val_t>
    void insert(NSString *key, Val_t value) {
        id val = s::create(value);
        [db setObject:val forKey:key];
    }
    
    NSMutableDictionary * release() {
        [db release];
        NSMutableDictionary *tmp = db;
        db = nil;
        return tmp;
    }
    
    
private:
    NSMutableDictionary *db;
};
 

    
}

