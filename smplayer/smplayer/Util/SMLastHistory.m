//
//  SMLastHistory.m
//  smplayer
//
//  Created by midoks on 2020/3/13.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMLastHistory.h"
#import "SMLastHistoryModel.h"
#import "SMCommon.h"

@interface SMLastHistory()

@property (nonatomic, strong) NSURL  *plistURL;
@property (nonatomic, strong) NSArray<SMLastHistoryModel *> *history;

@end

@implementation SMLastHistory

static SMLastHistory *_instance = nil;
static dispatch_once_t _instance_once;

+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[SMLastHistory alloc] init:[SMCommon playHistoryURL]];
    });
    return _instance;
}

-(id)init:(NSURL *)url{
    self  = [super init];
    if (self){
        self.plistURL = url;
    }
    
    _history = [[NSArray alloc] init];
    [self read];
    return self;
}

-(void)read{
    NSArray<SMLastHistoryModel *> *p = [NSKeyedUnarchiver unarchiveObjectWithFile:[_plistURL path]];
    NSLog(@"SMLastHistory:%@", p);
}

-(void)save{
    BOOL result =  [NSKeyedArchiver archiveRootObject:_history toFile:[_plistURL path]];
    if (result){
        NSLog(@"SMLastHistory dddddddd --- ok");
    }
}

-(void)add:(NSURL *)url duration:(double)duration{
//    NSLog(@"add:(NSURL *)url duration:(double)duration");
//    SMLastHistoryModel *shm = [[SMLastHistoryModel alloc] init:url duration:duration];
//    [_history insertValue:shm atIndex:(0) inPropertyWithKey:@""];
//    [self save];
}




@end
