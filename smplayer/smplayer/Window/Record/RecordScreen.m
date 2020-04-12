//
//  RecordScreen.m
//  smplayer
//
//  Created by midoks on 2020/4/12.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "RecordScreen.h"

@interface RecordScreen ()

@property (weak) IBOutlet  NSView *contentView;

@end

@implementation RecordScreen

-(id)init{
    self = [self initWithWindowNibName:@"RecordScreen"];
    return self;
}

static RecordScreen *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[RecordScreen alloc] init];
    });
    return _instance;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.movableByWindowBackground = YES;
    self.contentView.layer.cornerRadius = 5;
}


#pragma mark - Public Methods
-(IBAction)winClose:(id)sender{
    NSLog(@"close this window");
    [self.window close];
}

@end
