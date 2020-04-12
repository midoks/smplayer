//
//  AppDelegate.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMCore.h"
#import "OpenURL.h"
#import "SMCommon.h"
#import "MenuListController.h"

#import "MASPreferences.h"
#import "Preference.h"

#import <Sparkle/SUUpdater.h>

#import "AppDelegate.h"
#import "Preference.h"

#import "RecordScreen.h"

@interface AppDelegate ()
{
    NSWindowController *_preferenceWindow;
}
@property (weak) IBOutlet MenuListController *menuList;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [_menuList bindMenuItems];
    [self initPrefencesWindow];
    
    
    [[[SMCore Instance] first] showWindow:self];
    

    if([[Preference Instance] boolForKey:SM_PGG_AutomaticallyChecksForUpdates]){
        [[SUUpdater sharedUpdater] checkForUpdatesInBackground];
    }

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return [[Preference Instance] boolForKey:SM_PGG_QuitWhenNoOpenedWindow];
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
    [panel setPrompt:@"选择"];
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


-(void)initPrefencesWindow
{
    NSArray *listVC = @[
        [[PreferenceGeneral alloc] init],
        [[PreferenceCodec alloc] init],
        [[PreferenceSubtitle alloc] init],
        [[PreferenceNetwork alloc] init],
    ];
    
    _preferenceWindow = [[MASPreferencesWindowController alloc] initWithViewControllers:listVC title:@""];
    _preferenceWindow.window.level = NSFloatingWindowLevel;
}

#pragma mark - menu function
- (IBAction)showPreference:(id)sender {
    [_preferenceWindow showWindow:nil];
}

- (IBAction)openFile:(NSMenuItem *)sender {
    
    Player *player;
    if (sender.tag == 1){
        player = [[SMCore Instance] newPlayer];
    } else {
        player = [[SMCore Instance] player];
    }
    
    [player openSelectVideo:^{
        [[[SMCore Instance] first] close];
    }];
}

- (IBAction)openFileURL:(id)sender {
    [[OpenURL Instance] showWindow:self];
}

- (IBAction)openGithub:(id)sender {
    NSURL *url = [NSURL URLWithString:SM_AUTHOR_URL];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

#pragma mark - Record

-(IBAction)recordScreen:(id)sender{
    RecordScreen *rs = [RecordScreen Instance];
    [rs showWindow:self];
}

@end
