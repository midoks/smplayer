//
//  SMVideoTime.m
//  smplayer
//
//  Created by midoks on 2020/2/28.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMVideoTime.h"

@interface SMVideoTime()

@property double second;
@end

@implementation SMVideoTime

static SMVideoTime *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[SMVideoTime alloc] init];
    });
    return _instance;
}

-(double)doubleValue{
    return self.second;
}

-(int)intValue{
    return (int)self.second;
}

-(id)initTime:(double)time{
    self.second = time;
    return self;
}

-(int)getHour{
    return (int)self.second/3600;
}

-(int)getMinute{
    return ((int)self.second%3600)/60;
}

-(int)getSecond{
    return ((int)self.second%3600)%60;
}

-(NSString *)getString {
    NSString *f = @"";
    int s = [self getSecond];
    if (s<10){
        f = [NSString stringWithFormat:@"0%d",s];
    } else {
        f = [NSString stringWithFormat:@"%d",s];
    }
    
    int m = [self getMinute];
    if (m<10){
        f = [NSString stringWithFormat:@"0%d:%@", m,f];
    } else {
        f = [NSString stringWithFormat:@"%d:%@", m,f];
    }
    
    int h = [self getHour];
    if (h){
        f = [NSString stringWithFormat:@"%d:%@", h,f];
    }
    return f;
}

@end
