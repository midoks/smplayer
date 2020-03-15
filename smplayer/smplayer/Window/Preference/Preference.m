//
//  Preference.m
//  smplayer
//
//  Created by midoks on 2020/3/9.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "Preference.h"

@interface Preference ()<NSTableViewDelegate,NSTableViewDataSource>
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
}


@end
