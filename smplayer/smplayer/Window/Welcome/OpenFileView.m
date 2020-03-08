//
//  OpenFileView.m
//  smplayer
//
//  Created by midoks on 2020/3/9.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "OpenFileView.h"

@implementation OpenFileView

-(void)awakeFromNib{
    self.wantsLayer = YES;
    self.layer.cornerRadius = 4;
    [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.bounds
                                                       options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingActiveAlways
                                                         owner:self
                                                      userInfo:nil]];
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

-(void)mouseEntered:(NSEvent *)event{
    self.layer.backgroundColor = [NSColor colorWithCalibratedWhite:0 alpha:0.25].CGColor;
}

-(void)mouseExited:(NSEvent *)event{
    self.layer.backgroundColor = [NSColor colorWithCalibratedWhite:0 alpha:0].CGColor;
}

@end
