//
//  Preference.h
//  smplayer
//
//  Created by midoks on 2020/3/9.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PreferenceGeneral.h"
#import "PreferenceNetwork.h"
#import "PreferenceCodec.h"
#import "PreferenceSubtitle.h"


#pragma mark - preference gerenral
// Behavior
#define SM_PGG_ActionAfterLaunch @"actionAfterLaunch"
#define SM_PGG_AlwaysOpenInNewWindow @"alwaysOpenInNewWindow"
#define SM_PGG_AutomaticallyChecksForUpdates @"automaticallyChecksForUpdates"
#define SM_PGG_AlwaysOpenInNewWindow @"alwaysOpenInNewWindow"
#define SM_PGG_KeepOpenOnFileEnd @"keepOpenOnFileEnd"
#define SM_PGG_QuitWhenNoOpenedWindow @"quitWhenNoOpenedWindow"
#define SM_PGG_ResumeLastPosition @"resumeLastPosition"
// Screenshots
#define SM_PGG_ScreenshotSaveToFile @"screenshotSaveToFile"
#define SM_PGG_ScreenshotCopyToClipboard @"screenshotCopyToClipboard"
#define SM_PGG_ScreenShotIncludeSubtitle @"screenShotIncludeSubtitle"
#define SM_PGG_ScreenShotFormat @"screenShotFormat"
#define SM_PGG_ScreenShotFolder @"screenShotFolder"

#pragma mark - preference codec(video/audio)
#define SM_PGC_VideoThreads @"videoThreads"




NS_ASSUME_NONNULL_BEGIN

@interface Preference : NSObject

+ (id)Instance;

-(void)sync;
-(void)demo;

#pragma mark - GET
-(BOOL)boolForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
