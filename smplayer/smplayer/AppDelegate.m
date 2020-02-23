//
//  AppDelegate.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//


#import "AppDelegate.h"
#import "SMVideoView.h"

@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    int mask = NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|
    NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable;
    [self.window setStyleMask:mask];
    
    SMVideoView *player = [[SMVideoView alloc] initWithFrame:self.window.contentView.frame];
    self.window.contentView = player;
    
    [self.window makeKeyWindow];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
