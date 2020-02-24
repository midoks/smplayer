//
//  AppDelegate.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//


#import "AppDelegate.h"

@interface AppDelegate ()
@property NSWindowController *player;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    int mask = NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|
//    NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable;
//    [self.window setStyleMask:mask];
//
//    SMVideoView *player = [[SMVideoView alloc] initWithFrame:self.window.contentView.frame];
//    self.window.contentView = player;
//    [self.window makeKeyWindow];
    
    self.player =[[NSWindowController alloc] initWithWindowNibName:@"Player"];
    
    [self.player loadWindow];
    [self.player.window makeKeyWindow];
    [self.player.window makeMainWindow];
    [self.player.window center];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
