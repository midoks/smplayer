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
@property (strong) IBOutlet NSView *behaviorView;
@property (strong) IBOutlet NSView *testView;
@property (weak) IBOutlet NSStackView *baseView;

@end

@implementation PreferenceGeneral

-(id)init{
    self = [self initWithNibName:@"PreferenceGeneral" bundle:nil];
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad...");
//    _behaviorView.frame = NSMakeRect(0, 0, 300, 200);
//    _behaviorView.wantsLayer = YES;
//    _behaviorView.layer.backgroundColor = [NSColor redColor].CGColor;
//    [self.view addSubview:_behaviorView];
    
    NSBox *b = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, 100, 1)];
    b.boxType = NSBoxSeparator;
//
//    NSBox *b2 = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, 100, 1)];
//    b2.boxType = NSBoxSeparator;
    
//    NSArray *list = [NSArray arrayWithObjects:_behaviorView,nil];
//    _baseView = [NSStackView stackViewWithViews:list];
    
    [self.view addSubview:_behaviorView];
    [_baseView addSubview:b];

    _baseView.orientation = NSUserInterfaceLayoutOrientationVertical;
//    _baseView.alignment = NSLayoutAttributeLeading;
    _baseView.spacing = 0;
    _baseView.distribution = NSStackViewDistributionFill;

    for (int i = 0 ; i<[_baseView.views count]; i++) {
        NSLog(@"%@", _baseView.views[i]);
        [SMCommon quickConstraints:@[@"H:|-[v]-|"] view:@{@"v":_baseView.views[i]}];
    }
//    [self.view addSubview:stackView];
//    [SMCommon quickConstraints:@[@"H:|-[v]-|"] view:@{@"v":_baseView}];
    
//    [self.view addSubview:_baseView];
}

@end
