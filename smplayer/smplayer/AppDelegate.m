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

    
    player =[[Player alloc] initWithWindowNibName:@"Player"];
    
    [player.window makeKeyWindow];
    [player.window makeMainWindow];
    [player.window center];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
}


@end
