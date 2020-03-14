//
//  OpenURL.m
//  smplayer
//
//  Created by midoks on 2020/3/10.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "OpenURL.h"

@interface OpenURL ()

@end

@implementation OpenURL

static OpenURL *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[OpenURL alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [self initWithWindowNibName:@"OpenURL"];
    return self;
}

-(id)initWithWindow:(NSWindow *)window {
    if (self = [super initWithWindow:window]) {
        [self loadWindow];
    }
    return self;
}

-(void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.movableByWindowBackground = YES;
    
}

@end
