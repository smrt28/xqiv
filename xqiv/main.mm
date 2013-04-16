//
//  main.m
//  xqiv
//
//  Created by smrt on 3/16/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ns-array.h"
#import "ns-dict.h"

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

class XXX_t {};


int main(int argc, char *argv[])
{
    A_t *x = [[A_t alloc]init];
    
    {
        ns::array_t a;
        a.push_back(x);
        [x release];
        
        ns::array_t c;
        c.push_back(x);
        c.push_back(a);
        c[1].as<NSMutableArray>();
        ns::array_t d;
        d = c[1].as<ns::array_t>();
    }
    
    ns::dict_t d1;
    ns::dict_t d2;
    
    d1.insert(@"sub", d2);
    
  //  d1[@"sub"].as<ns::dict_t>().insert(@"key", [NSNumber numberWithInt:1]);

    
    return NSApplicationMain(argc, (const char **)argv);
}
