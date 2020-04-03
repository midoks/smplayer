//
//  PreferenceGeneral.m
//  smplayer
//
//  Created by midoks on 2020/3/15.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMCommon.h"
#import "Preference.h"

#import "PreferenceGeneral.h"

@interface PreferenceGeneral ()

@end

@implementation PreferenceGeneral

-(id)init{
    self = [self initWithNibName:@"PreferenceGeneral" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(IBAction)choooseScreenshotPathAction:(id)sender
{
    
    NSString *path = [[Preference Instance] stringForKey:SM_PGG_ScreenShotFolder];
    [SMCommon quickOpenPanel:@"Choose screenshot save path"
                   chooseDir:YES
                         dir:[NSURL URLWithString:path]
                    callback:^(NSURL * _Nonnull url) {
        [[Preference Instance] setString:[url path] key:SM_PGG_ScreenShotFolder];
        [[Preference Instance] sync];
    }];
}

#pragma mark - MASPreferencesViewController
- (NSString *)viewIdentifier
{
    return @"PreferenceGeneral";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"preference.general", @"");
}

@end
