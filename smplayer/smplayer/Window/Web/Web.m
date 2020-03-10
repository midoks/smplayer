//
//  Web.m
//  smplayer
//
//  Created by midoks on 2020/3/9.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "Web.h"

@interface Web ()<NSWindowDelegate>
{
    NSView *titleBarView;
}

@end

@implementation Web

-(id)init{
    self = [self initWithWindowNibName:@"Web"];
    return self;
}
-(id)initWithWindow:(NSWindow *)window
{
    if (self = [super initWithWindow:window]) {
        [self loadWindow];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.movableByWindowBackground = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    
    NSButton *zoomBtn = [self.window standardWindowButton:NSWindowZoomButton];
    NSView *s = [zoomBtn superview];
    titleBarView = [s superview];
    
    [self setTitleBarView:self.window.frame.size];
}

-(NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize{
    NSLog(@"frameSize:%@", NSStringFromSize(frameSize));
    [self setTitleBarView:frameSize];
    return frameSize;
}


-(void)setTitleBarView:(NSSize)size{
    
    titleBarView.wantsLayer = YES;
    titleBarView.layer.backgroundColor = [NSColor redColor].CGColor;
    NSLog(@"%@", NSStringFromSize(size));
    titleBarView.frame = CGRectMake(0, size.height-50, size.width, 50);
}

@end
