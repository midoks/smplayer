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
}


-(void)chooseSubFontAction{
    
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
    return NSLocalizedString(@"preference.subtitle", nil);
    
}

@end
