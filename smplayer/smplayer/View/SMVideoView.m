//
//  SMVideoView.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMVideoTime.h"
#import "SMVideoView.h"


@interface SMVideoView ()

@end

@implementation SMVideoView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        _smLayer = [[SMVideoLayer alloc] init];
        self.layer = _smLayer;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end
