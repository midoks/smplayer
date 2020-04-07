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
    
    NSMutableArray *list = [[[SMCore Instance] player].mpv getNode:@"audio-device-list"];
    NSString *audioDevice = [[Preference Instance] stringForKey:SM_PGC_AudioDevice];
    for (NSDictionary *info in list){
        NSString *title = [NSString stringWithFormat:@"[%@] %@", [info objectForKey:@"description"], [info objectForKey:@"name"] ];
        [_audioDevicePopUp addItemWithTitle:title];
        _audioDevicePopUp.lastItem.representedObject = info;
        
        if ([audioDevice isEqualToString:[info objectForKey:@"name"]]){
            [_audioDevicePopUp selectItem:_audioDevicePopUp.lastItem];
        }
    }
}

-(IBAction)audioDeviceAction:(NSMenuItem *)sender{
    NSString *name = [sender.representedObject objectForKey:@"name"];
    [[Preference Instance] setString:name key:SM_PGC_AudioDevice];
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
