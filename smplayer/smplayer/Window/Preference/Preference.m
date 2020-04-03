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
        SM_PGG_ScreenshotSaveToFile:@YES,
        SM_PGG_ScreenShotFolder:@"~/Pictures/Screenshots",
        SM_PGG_ScreenShotIncludeSubtitle:@YES,
        SM_PGC_VideoThreads:@0,
        
        SM_PGN_EnableCache:@YES,
        SM_PGN_DefaultCacheSize:@153600,
        SM_PGN_SecPrefech:@100,
    }];
    return self;
}

-(NSUserDefaults *)standardUserDefaults {
    return [NSUserDefaults standardUserDefaults];
}

-(void)demo{
    NSUserDefaults *nd = [self standardUserDefaults];
    NSLog(@"demo:%@", [nd objectForKey:SM_PGG_ActionAfterLaunch]);
    
}

-(void)sync{
    [[self standardUserDefaults] synchronize];
}

#pragma mark - SET
-(void)setString:(NSString *)value key:(NSString*)key{
    [[self standardUserDefaults] setValue:value forKey:key];
}

-(void)setBool:(BOOL)value key:(NSString*)key{
    [[self standardUserDefaults] setBool:value forKey:key];
}

#pragma mark - GET
-(BOOL)boolForKey:(NSString *)key
{
    return [[self standardUserDefaults] boolForKey:key];
}

-(NSString *)stringForKey:(NSString *)key
{
    return [[self standardUserDefaults] stringForKey:key];
}


@end
