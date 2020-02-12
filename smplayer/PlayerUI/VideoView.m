//
//  VideoView.m
//  smplayer
//
//  Created by midoks on 2020/2/12.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "VideoView.h"

@implementation VideoView

- (id)initWithFrame:(NSRect)frame{
    self.frame = frame;
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = true;
        self.layer.backgroundColor = [NSColor brownColor].CGColor;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
