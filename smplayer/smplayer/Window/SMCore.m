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

@interface SMCore()
{
    Welcome *welcome;
    Preference *preference;
}

@property (nonatomic,strong) Player* nowPlayer;
@property (nonatomic,strong) NSMutableArray<Player*>* playerList;
@property (nonatomic,assign) NSInteger playerCount;


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
        self->preference = [Preference Instance];
        
        _nowPlayer = [Player Instance];
        _playerList = [[NSMutableArray alloc] initWithObjects:_nowPlayer, nil];
        _playerCount = 1;
    }
    return self;
}

-(Welcome *)first{
    return self->welcome;
}

-(Player *)player{
//    NSLog(@"player...:%@",_nowPlayer.info);
    return _nowPlayer;
}

-(Player *)newPlayer{
    NSLog(@"new:::player");
//    for (Player *p in _playerList) {
//
//    }
    
    if ([[Preference Instance] boolForKey:SM_PGG_AlwaysOpenInNewWindow]){
        Player *newPlayer = [[Player alloc] init];
        [_playerList addObject:newPlayer];
        _playerCount += 1;
        _nowPlayer = newPlayer;
        return newPlayer;
    }
    return _nowPlayer;
}

-(Player *)activePlayer{
//    if([[NSApp mainWindow] isKindOfClass:[Player class]]){
//        return (Player *)[NSApp mainWindow];
//    }
    return _nowPlayer;
}

-(Preference *)preference{
    return self->preference;
}




@end
