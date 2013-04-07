//
//  SDictionary.m
//  xqiv
//
//  Created by smrt on 3/23/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "SDictionary.h"

namespace s {
    Dictionary_t::Dictionary_t() :
        db([[NSMutableDictionary alloc] init])
    {
        [db autorelease];
        [db retain];
    }
    
    
    Dictionary_t::Dictionary_t(NSMutableDictionary *db) :
        db(db)
    {
        [db retain];
    }
    
    Dictionary_t::~Dictionary_t() {
        [db release];
    }
    
    id Dictionary_t::operator[](NSString *s) {
        return [db objectForKey:s];
    }
    
    id Dictionary_t::operator[](const char *s) {
        return [db objectForKey:[NSString stringWithUTF8String:s]];
    }
    
    void Dictionary_t::remove(NSString *s) {
        [db removeObjectForKey:s];
    }
    
    void Dictionary_t::insert(NSString *key, id obj) {
        [db setObject:obj forKey:key];
    }
    
    void Dictionary_t::remove(const char *s) {
        [db removeObjectForKey:[NSString stringWithUTF8String:s]];
    }
    
    void Dictionary_t::insert(const char *key, id obj) {
        [db setObject:obj forKey:[NSString stringWithUTF8String:key]];
    }
    
    void Dictionary_t::insert(NSString *key, Dictionary_t &dict) {
        insert(key, dict.objc());
    }
    
    void Dictionary_t::insert(const char *key, Dictionary_t &dict) {
        insert(key, dict.objc());
    }

}