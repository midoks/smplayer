//
//  PreferenceCodec.m
//  smplayer
//
//  Created by midoks on 2020/3/30.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMCore.h"
#import "Preference.h"

#import "PreferenceCodec.h"

@interface PreferenceCodec ()

@property (weak) IBOutlet NSTextField *hwdecDescriptionTextField;
@property (weak) IBOutlet NSPopUpButton *audioDevicePopUp;

@end

@implementation PreferenceCodec

-(id)init{
    self = [self initWithNibName:@"PreferenceCodec" bundle:nil];
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    [self updateHwdecDescription];
}

-(void)viewWillAppear{
    [_audioDevicePopUp removeAllItems];
    
    [[[SMCore Instance] player].mpv getNode:@"audio-device-list"];
}

-(IBAction)hwdecAction:(id)sender{
    [self updateHwdecDescription];
}

-(void)updateHwdecDescription {
    NSInteger index =  [[Preference Instance] integerForKey:SM_PGC_HardwareDecoder];
    NSString *desc = [[Preference Instance] hardwareDecoderOptionToString:index];
    NSString *hardwareDesc = [NSString stringWithFormat:@"hwdec.%@", desc];
    [_hwdecDescriptionTextField setStringValue:NSLocalizedString(hardwareDesc, @"")];
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
