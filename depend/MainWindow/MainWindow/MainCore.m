//
//  MainCore.m
//  MainWindow
//
//  Created by midoks on 2021/2/1.
//

#import "MainCore.h"

@interface MainCore()
{
    Web *web;
}


@end


@implementation MainCore

static MainCore *_instance = nil;
static dispatch_once_t _instance_once;

+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[MainCore alloc] init];
    });
    return _instance;
}
-(id)init{
    self = [super init];
    if (self){
        self->web = [Web Instance];
    }
    return self;
}


-(Web *)web{
    return self->web;
}

@end
