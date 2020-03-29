//
//  PreferenceGeneral.m
//  smplayer
//
//  Created by midoks on 2020/3/15.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "PreferenceGeneral.h"

#import "SMCommon.h"

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
    return NSLocalizedString(@"General", @"");
}

@end
