//
//  PreferenceCodec.m
//  smplayer
//
//  Created by midoks on 2020/3/30.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "PreferenceCodec.h"

@interface PreferenceCodec ()

@end

@implementation PreferenceCodec

-(id)init{
    self = [self initWithNibName:@"PreferenceCodec" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - MASPreferencesViewController

- (NSString *)viewIdentifier
{
    return @"PreferenceCodec";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameTouchBarCommunicationVideoTemplate];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"preference.codec", @"");
}

@end
