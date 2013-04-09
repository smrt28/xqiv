//
//  main.m
//  xqiv
//
//  Created by smrt on 3/16/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ns-object.h"

@interface A_t : NSObject
@property (readwrite,assign) int val;
@end

@implementation A_t

-(id)init {
    NSLog(@"A_t init");
    self = [super init];
    return self;
}

- (void)dealloc {
    NSLog(@"A_t dealloc");
    [super dealloc];
}


@end

class B_t {
public:
    ns::object_t<A_t> a;
};

int main(int argc, char *argv[])
{
    @autoreleasepool {
        ns::object_t<NSMutableDictionary> dict;
        ns::object_t<NSString> s(@"ahoj");
        
        //TODO: ns::object_t<NSNumber> n(10);
        ns::object_t<NSNumber> n([NSNumber numberWithInt:12]);
        dict->objc();
        
        dict->insert(@"abc", s);
        dict->insert(@"aaa", n);
        NSLog(@"%@", dict[@"abc"].as<NSString>());
        
        ns::object_t<NSString> abc(dict[@"abc"]);
        NSLog(@"%@", abc.objc());
        
        //TODO:
      //  dict[@"aaa"].as<int>();
        
        NSLog(@"%d", dict[@"aaa"].as<int>());
      
    }

    
    @autoreleasepool {
        ns::object_t<A_t> a1;
        ns::object_t<A_t> a2;
        ns::object_t<A_t> a3;
        ns::object_t<A_t> a4;
        ns::object_t<A_t> a5;
        ns::object_t<id> d;
        
        a1.objc().val = 10;
//        a1 = d.as<A_t>();
        
        a2 = a1;
        d = a2;
        a1 = a5;
        a4 = d;
        a1 = nil;
        NSLog(@"%d", a4.objc().val);
    }
    
    
    return NSApplicationMain(argc, (const char **)argv);
}
