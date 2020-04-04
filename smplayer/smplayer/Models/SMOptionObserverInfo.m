//
//  SMOptionObserverInfo.m
//  smplayer
//
//  Created by midoks on 2020/4/5.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMOptionObserverInfo.h"

@implementation SMOptionObserverInfo

-(id)init:(NSString *)key
     name:(NSString *)name
   option:(SMUserOption)option
callback:(NSString* (^)(NSString *key))callback
{
    self = [super init];
    self.key = key;
    self.name = name;
    self.option = option;
    self.callback = callback;
    return self;
}
@end
