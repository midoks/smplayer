//
//  SMPlayerInfo.m
//  smplayer
//
//  Created by midoks on 2020/3/20.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMPlayerInfo.h"

@implementation SMPlayerInfo

-(id)init{
    self = [super init];
    if (self){
        _isPause = NO;
        _playSpeed = 1;
        _width = 0;
        _height = 0;
        
    }
    return self;
}

@end
