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
