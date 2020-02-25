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


#pragma mark - URL Schemes
- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls{

    [player openVideo:[urls[0] path]];
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert setInformativeText:[NSString stringWithFormat:@"%@", [urls[0] path] ]];
//    [alert beginSheetModalForWindow:player.window
//                  completionHandler:^(NSModalResponse returnCode){
//        //用户点击告警上面的按钮后的回调
//        NSLog(@"returnCode : %ld",(long)returnCode);
//    }];
}

@end
