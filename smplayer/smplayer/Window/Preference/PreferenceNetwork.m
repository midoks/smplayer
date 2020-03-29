//
//  PreferenceNetwork.m
//  smplayer
//
//  Created by midoks on 2020/3/16.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "PreferenceNetwork.h"

@interface PreferenceNetwork ()

@property (strong) IBOutlet NSView *cacheView;

@end

@implementation PreferenceNetwork

-(id)init{
    self = [self initWithNibName:@"PreferenceNetwork" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:_cacheView];
}

#pragma mark - MASPreferencesViewController

- (NSString *)viewIdentifier
{
    return @"PreferenceNetwork";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameNetwork];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Network", nil);
}

@end
