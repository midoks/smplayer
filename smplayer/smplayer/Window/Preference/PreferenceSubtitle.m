//
//  PreferenceSubtitle.m
//  smplayer
//
//  Created by midoks on 2020/3/30.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "PreferenceSubtitle.h"

@interface PreferenceSubtitle ()

@end

@implementation PreferenceSubtitle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

#pragma mark - MASPreferencesViewController

- (NSString *)viewIdentifier
{
    return @"PreferenceSubtitle";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameFontPanel];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Subtitle", nil);
}

@end
