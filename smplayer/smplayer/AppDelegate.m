//
//  AppDelegate.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//


#import "AppDelegate.h"
#import "Player.h"

@interface AppDelegate (){
    Player *player;
}
//@property (weak)
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
    
    player =[[Player alloc] initWithWindowNibName:@"Player"];
    
    [player loadWindow];
    [player.window makeKeyWindow];
    [player.window makeMainWindow];
    [player.window center];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
}


@end
