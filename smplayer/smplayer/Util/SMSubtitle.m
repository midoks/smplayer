//
//  SMSubtitle.m
//  smplayer
//
//  Created by midoks on 2020/3/26.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMSubtitle.h"
#import "SMSubtitleShooter.h"

@implementation SMSubtitle

static SMSubtitle *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[SMSubtitle alloc] init];
    });
    return _instance;
}

-(void)get:(NSURL *)file{
//    NSLog(@"SMSubtitle:%@", file);
    [[SMSubtitleShooter Instance] request:file];
    
    
}

@end
