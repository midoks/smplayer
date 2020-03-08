//
//  SMCore.m
//  smplayer
//
//  Created by midoks on 2020/3/8.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "Welcome.h"
#import "Player.h"

#import "SMCore.h"

@interface SMCore()
{
    Welcome *welcome;
    Player *player;
}
@end

@implementation SMCore

static SMCore *_instance = nil;
static dispatch_once_t _instance_once;

+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[SMCore alloc] init];
    });
    return _instance;
}
-(id)init{
    self = [super init];
    if (self){
        self->welcome = [Welcome Instance];
        self->player = [Player Instance];
    }
    return self;
}

-(void)first{
    [self->welcome showWindow:nil];
}


@end
