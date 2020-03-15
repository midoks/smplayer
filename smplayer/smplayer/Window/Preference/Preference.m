//
//  Preference.m
//  smplayer
//
//  Created by midoks on 2020/3/9.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "Preference.h"
#import "PreferenceGeneral.h"
#import "SMCommon.h"

@interface Preference ()<NSTableViewDelegate,NSTableViewDataSource>
{
    PreferenceGeneral *prefGeneral;
}


@property (weak) IBOutlet NSStackView *baseView;


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
    self = [self initWithWindowNibName:@"Preference"];
    prefGeneral = [[PreferenceGeneral alloc] initWithNibName:@"PreferenceGeneral" bundle:nil];
    return self;
}
-(id)initWithWindow:(NSWindow *)window
{
    if (self = [super initWithWindow:window]) {
        [self loadWindow];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.movableByWindowBackground = YES;
    
    
    self.contentViewController = prefGeneral;
//    [self.window.contentView addSubview:prefGeneral.view];
    
//    [self.baseView addSubview:prefGeneral.view];
    
    
//    self.window.contentView = prefGeneral.view;
    
//    [SMCommon quickConstraints:@[@"H:|-20-[v]-20-|"]
//                          view:@{@"v":prefGeneral.view}];
}

-(IBAction)generalAction:(NSToolbarItem *)sender{
    

    NSLog(@"dddd:%ld",(long)sender.tag);
    
}
@end
