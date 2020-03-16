//
//  AppDelegate.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//


#import "AppDelegate.h"
#import "SMCore.h"
#import "OpenURL.h"
#import "Preference.h"

@interface AppDelegate ()
@property OpenURL *openURL;

@property Preference *pref;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[[SMCore Instance] first] showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}


#pragma mark - URL Schemes
- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls{
    
    [[[SMCore Instance] player] showWindow:self];
    [[[SMCore Instance] player] openVideo:[urls[0] path]];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setInformativeText:[NSString stringWithFormat:@"%@", urls ]];
    [alert beginSheetModalForWindow:[[SMCore Instance] player].window
                  completionHandler:^(NSModalResponse returnCode){
        //用户点击告警上面的按钮后的回调
        NSLog(@"returnCode : %ld",(long)returnCode);
    }];
}

-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{
 
    if ([filename isNotEqualTo:@""]){
        [[[SMCore Instance] first] close];
        [[[SMCore Instance] player] showWindow:self];
        [[[SMCore Instance] player] openVideo:filename];
        return YES;
    }
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setPrompt: @"选择"];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:YES];
    panel.allowsMultipleSelection = YES;
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"mp4"]];
    
    if([panel runModal]){
        [[[SMCore Instance] first] close];
        [[[SMCore Instance] player] showWindow:self];
        [[[SMCore Instance] player] openVideo:[[panel URL] path]];
    }
    return YES;
}

-(BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag{
  if (!flag){
    [NSApp activateIgnoringOtherApps:NO];
    [[[SMCore Instance] first] showWindow:self];
  }
  return YES;
}


#pragma mark - menu function
- (IBAction)showPreference:(id)sender {
    [[[SMCore Instance] preference] showWindow:self];
}

- (IBAction)openFile:(id)sender {
    [[[SMCore Instance] player] openSelectVideo:^{
        [[[SMCore Instance] first] close];
    }];
}

- (IBAction)openFileURL:(id)sender {
    [[OpenURL Instance] showWindow:self];
}


@end
