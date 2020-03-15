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
#import "Preference.h"
#import "Web.h"

@interface SMCore()
{
    Welcome *welcome;
    Player *player;
    Web *web;
    Preference *preference;
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
        self->web = [Web Instance];
        self->preference = [Preference Instance];
    }
    return self;
}

-(Welcome *)first{
    return self->welcome;
}

-(Player *)player{
    return self->player;
}

-(Web *)web{
    return self->web;
}

-(Preference *)preference{
    return self->preference;
}




@end
