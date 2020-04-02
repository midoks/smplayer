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
        SM_PGC_VideoThreads:@0,
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

#pragma mark - GET
-(BOOL)boolForKey:(NSString *)key
{
    return [[self standardUserDefaults] boolForKey:key];
}


@end
