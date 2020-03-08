//
//  AppDelegate.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//


#import "AppDelegate.h"
#import "SMCore.h"

@interface AppDelegate (){
//    Player *player;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
//    [self initPlayer];
//    [self regListenEvent];
    [[SMCore Instance] first];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    NSLog(@"%@",@"dddd");
}


#pragma mark - URL Schemes
- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls{
    [self initPlayer];
//    [player openVideo:[urls[0] path]];
    
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert setInformativeText:[NSString stringWithFormat:@"%@", urls ]];
//    [alert beginSheetModalForWindow:player.window
//                  completionHandler:^(NSModalResponse returnCode){
//        //用户点击告警上面的按钮后的回调
//        NSLog(@"returnCode : %ld",(long)returnCode);
//    }];
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag{
  if (!flag){
    [NSApp activateIgnoringOtherApps:NO];
    [[SMCore Instance] first];
//    [self.window makeKeyAndOrderFront:self];
  }
  return YES;
}

-(void)initPlayer{
//    if (!player){
//        player = [[Player];
//        [player.window makeKeyWindow];
//        [player.window makeMainWindow];
//
//        [player showWindow:self];
//        [player.window makeKeyAndOrderFront:NULL];
//    }
}

-(void)regListenEvent{
}


@end
