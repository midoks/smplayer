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
    [self initPlayer];
    [self regListenEvent];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    NSLog(@"%@",@"dddd");
}


#pragma mark - URL Schemes
- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls{
    [self initPlayer];
    [player openVideo:[urls[0] path]];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setInformativeText:[NSString stringWithFormat:@"%@", urls ]];
    [alert beginSheetModalForWindow:player.window
                  completionHandler:^(NSModalResponse returnCode){
        //用户点击告警上面的按钮后的回调
        NSLog(@"returnCode : %ld",(long)returnCode);
    }];
}

-(void)initPlayer{
    if (!player){
        player =[[Player alloc] initWithWindowNibName:@"Player"];
        [player.window makeKeyWindow];
        [player.window makeMainWindow];
        [player.window center];
    }
}

-(void)regListenEvent{
    
    
//    [NSEvent addLocalMonitorForEventsMatchingMask:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
//    NSTrackingCursorUpdate |
//    NSTrackingActiveWhenFirstResponder |
//    NSTrackingActiveInKeyWindow |
//    NSTrackingActiveInActiveApp |
//    NSTrackingActiveAlways |
//    NSTrackingAssumeInside |
//    NSTrackingInVisibleRect |
//     NSTrackingEnabledDuringMouseDrag handler:(NSEvent * event) {
//
//    }];
    
//    [NSEvent addLocalMonitorForEventsMatchingMask:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
//    NSTrackingCursorUpdate |
//    NSTrackingActiveWhenFirstResponder |
//    NSTrackingActiveInKeyWindow |
//    NSTrackingActiveInActiveApp |
//    NSTrackingActiveAlways |
//    NSTrackingAssumeInside |
//    NSTrackingInVisibleRect |
//     NSTrackingEnabledDuringMouseDrag handler:^NSEvent * _Nullable(NSEvent * _Nonnull) {
//        NSLog(@"123" );
//    }];
    
//    [NSEvent addGlobalMonitorForEventsMatchingMask:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
//    NSTrackingCursorUpdate |
//    NSTrackingActiveInKeyWindow |
//    NSTrackingActiveInActiveApp |
//    NSTrackingActiveAlways |
//    NSTrackingAssumeInside |
//    NSTrackingInVisibleRect |
//    NSTrackingEnabledDuringMouseDrag handler:^(NSEvent * event) {
//        NSLog(@"%@", event);
//    }];
}


@end
