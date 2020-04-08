//
//  Preference.m
//  smplayer
//
//  Created by midoks on 2020/3/9.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "Preference.h"
#import "PreferenceGeneral.h"
#import "PreferenceNetwork.h"
#import "MASPreferences.h"

#import "SMCommon.h"

@interface Preference ()<NSTableViewDelegate,NSTableViewDataSource>
{
}


@end

@implementation Preference

static Preference *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[Preference alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [super init];
    
    [[self standardUserDefaults] registerDefaults:@{
        SM_PGG_ActionAfterLaunch:@0,
        SM_PGG_KeepOpenOnFileEnd:@YES,
        SM_PGG_ScreenshotSaveToFile:@YES,
        SM_PGG_ScreenShotFolder:@"~/Pictures/Screenshots",
        SM_PGG_ScreenShotTemplate:@"%F-%n",
        SM_PGG_ScreenShotIncludeSubtitle:@YES,
        SM_PGG_ScreenshotOkToOpen:@YES,
        
        
        SM_PGC_VideoThreads:@0,
        SM_PGC_HardwareDecoder:@1,
        SM_PGC_InitialVolume:@60,
        SM_PGC_MaxVolume:@100,
        SM_PGC_AudioThreads:@0,
        SM_PGC_AudioDevice:@"auto",
        SM_PGC_SpdifDTS:@YES,
        SM_PGC_SpdifAC3:@YES,
        SM_PGC_SpdifDTSHD:@YES,
        
        
        
        SM_PGS_SubTextFont:@"sans-serif",
        SM_PGS_SubTextSize:@55,
        SM_PGS_SubBold:@YES,
        SM_PGS_SubItalic:@NO,
        SM_PGS_SubTextColor:[NSKeyedArchiver archivedDataWithRootObject:[NSColor whiteColor]],
        SM_PGS_SubBgColor:[NSKeyedArchiver archivedDataWithRootObject:[NSColor clearColor]],
        SM_PGS_SubBorderSize:@3,
        SM_PGS_SubBorderColor:[NSKeyedArchiver archivedDataWithRootObject:[NSColor clearColor]],
        SM_PGS_SubAlignX:@1,
        SM_PGS_SubAlignY:@2,
        SM_PGS_SubMarginX:@25,
        SM_PGS_SubMarginY:@22,
        SM_PGS_SubPos:@100,
        SM_PGS_DisplayInLetterBox:@YES,
        SM_PGS_SubScaleWithWindow:@YES,
        SM_PGS_AutoSearchOnlineSub:@YES,
        
        // network
        SM_PGN_EnableCache:@YES,
        SM_PGN_DefaultCacheSize:@153600,
        SM_PGN_SecPrefech:@36000,
        SM_PGN_TransportRTSPThrough:@1,
        SM_PGN_YtdlEnabled:@NO,
        SM_PGN_UserAgent:@"",
    }];
    return self;
}

-(NSUserDefaults *)standardUserDefaults {
    return [NSUserDefaults standardUserDefaults];
}

-(void)sync{
    [[self standardUserDefaults] synchronize];
}

#pragma mark - Public Methods
-(NSString *)subAlignXToString:(NSInteger)index{
    NSArray *list = @[@"left",@"center",@"right"];
    return [list objectAtIndex:index];
}

-(NSString *)subAlignYToString:(NSInteger)index{
    NSArray *list = @[@"top",@"center",@"bottom"];
    return [list objectAtIndex:index];
}

-(NSString *)hardwareDecoderOptionToString:(NSInteger)index{
    NSArray *list = @[@"no",@"auto",@"auto-copy"];
    return [list objectAtIndex:index];
}

-(NSString *)rtspTransportationOptionToString:(NSInteger)index{
    NSArray *list = @[@"lavf",@"tcp",@"udp",@"http"];
    return [list objectAtIndex:index];
}

-(NSString *)screenshotFormatToString:(NSInteger)index{
    NSArray *list = @[@"png",@"jpg",@"jpeg",@"ppm",@"pgm",@"pgmyuv",@"tga"];
    return [list objectAtIndex:index];
}


#pragma mark - SET
-(void)setString:(NSString *)value key:(NSString*)key{
    [[self standardUserDefaults] setValue:value forKey:key];
}

-(void)setBool:(BOOL)value key:(NSString*)key{
    [[self standardUserDefaults] setBool:value forKey:key];
}

-(void)setInteger:(NSInteger)value key:(NSString *)key{
    [[self standardUserDefaults] setInteger:value forKey:key];
}


#pragma mark - GET
-(BOOL)boolForKey:(NSString *)key{
    return [[self standardUserDefaults] boolForKey:key];
}

-(float)floatForKey:(NSString *)key{
    return [[self standardUserDefaults] floatForKey:key];
}

-(NSString *)stringForKey:(NSString *)key{
    return [[self standardUserDefaults] stringForKey:key];
}

-(NSInteger)integerForKey:(NSString *)key{
    return [[self standardUserDefaults] integerForKey:key];
}

-(NSString *)colorForKey:(NSString *)key{
    NSData *data = [[self standardUserDefaults] dataForKey:key];
    NSColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (color){
        color = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
        NSString *result = [NSString stringWithFormat:@"%.1f/%.1f/%.1f/%.1f", color.redComponent, color.greenComponent,color.blueComponent,color.alphaComponent];
        return result;
    }
    return @"";
}


@end
