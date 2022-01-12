//
//  SMCore.h
//  smplayer
//
//  Created by midoks on 2020/3/8.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Welcome.h"
#import "Player.h"
#import "Preference.h"

NS_ASSUME_NONNULL_BEGIN

@interface SMCore : NSObject

+ (id)Instance;

-(Welcome *)first;
-(Player *)player;
-(Player *)newPlayer;
-(Player *)activePlayer;
-(Preference *)preference;

@end

NS_ASSUME_NONNULL_END
