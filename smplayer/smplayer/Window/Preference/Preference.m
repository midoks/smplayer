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

#import "SMCommon.h"

@interface Preference ()<NSTableViewDelegate,NSTableViewDataSource>
{
    
    NSDictionary * list;
    
    PreferenceGeneral *prefGeneral;
    PreferenceNetwork *prefNetwork;
}


@property (weak) IBOutlet NSStackView *baseStackView;
@property (weak) IBOutlet NSScrollView *baseView;


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
    prefGeneral = [[PreferenceGeneral alloc] init];
    prefNetwork = [[PreferenceNetwork alloc] init];
    
    list = @{
        @"general":prefGeneral,
        @"network":prefNetwork,
             
    };
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
//
//    [self.baseView addSubview:prefGeneral.view];
//
//
//    self.window.contentView.wantsLayer = YES;
//    self.window.contentView.layer.backgroundColor = [NSColor yellowColor].CGColor;
//
//    [SMCommon quickConstraints:@[@"H:|-[v]-|",@"V:|-[v]-|"]
//                          view:@{@"v":prefGeneral.view}];
    
//    [SMCommon quickConstraints:@[@"H:|-2-[v]-2-|",@"V:|-2-[v]-2-|"]
//                          view:@{@"v":self.baseView}];
}

-(IBAction)commonAction:(NSToolbarItem *)sender{

    self.window.title = sender.itemIdentifier;
    NSViewController *c = [list objectForKey:sender.itemIdentifier];
    self.contentViewController = c;
}
@end
