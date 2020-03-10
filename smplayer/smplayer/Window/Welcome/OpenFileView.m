//
//  OpenFileView.m
//  smplayer
//
//  Created by midoks on 2020/3/9.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "OpenFileView.h"
#import "Web.h"

@implementation OpenFileView

-(void)awakeFromNib{
    self.wantsLayer = YES;
    self.layer.cornerRadius = 4;
}

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.bounds
                                                       options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingMouseMoved | NSTrackingActiveAlways
                                                         owner:self
                                                      userInfo:nil]];
}

-(void)mouseEntered:(NSEvent *)event{
    self.layer.backgroundColor = [NSColor colorWithCalibratedWhite:0 alpha:0.25].CGColor;
}

-(void)mouseExited:(NSEvent *)event{
    self.layer.backgroundColor = [NSColor colorWithCalibratedWhite:0 alpha:0].CGColor;
}

-(void)mouseDown:(NSEvent *)event{
    
    if ([self.identifier isEqualToString:@"open-file"]){
        [[NSApp delegate] application:[NSApplication sharedApplication] openFile:@""];
    } else if ([self.identifier isEqualToString:@"open-fileurl"]){

//        NSApplicationDelegate nd = [NSApp delegate];
//        [nd open]
//        [(AppDelegate*)nd open];
//        [[NSApp delegate] application:[NSApplication sharedApplication] open:];
        Web *w = [[Web alloc] init];
        [w showWindow:nil];
    } else if ([self.identifier isEqualToString:@"open-resume"]){
    }
}

-(void)mouseUp:(NSEvent *)event{
//    NSLog(@"dddss");
}

@end
