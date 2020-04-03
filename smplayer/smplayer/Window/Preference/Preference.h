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
#define SM_PGC_HardwareDecoder @"hardwareDecoder"
#define SM_PGC_InitialVolume @"initialVolume"
#define SM_PGC_MaxVolume @"maxVolume"
#define SM_PGC_AudioThreads @"audioThreads"
#define SM_PGC_SpdifAC3 @"spdifAC3"
#define SM_PGC_SpdifDTS @"spdifDTS"
#define SM_PGC_SpdifDTSHD @"spdifDTSHD"




#pragma mark - preference network
#define SM_PGN_EnableCache @"enableCache"
#define SM_PGN_DefaultCacheSize @"defaultCacheSize"
#define SM_PGN_SecPrefech @"secPrefech"
#define SM_PGN_UserAgent @"userAgent"
#define SM_PGN_HttpProxy @"httpProxy"
#define SM_PGN_TransportRTSPThrough @"transportRTSPThrough"
#define SM_PGN_YtdlEnabled @"ytdlEnabled"
#define SM_PGN_YtdlSearchPath @"ytdlSearchPath"
#define SM_PGN_YtdlRawOptions @"ytdlRawOptions"



NS_ASSUME_NONNULL_BEGIN

@interface Preference : NSObject

+ (id)Instance;

-(void)sync;
-(void)demo;

#pragma mark - SET
-(void)setString:(NSString *)value key:(NSString*)key;
-(void)setBool:(BOOL)value key:(NSString*)key;

#pragma mark - GET
-(BOOL)boolForKey:(NSString *)key;
-(NSString *)stringForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
