//
//  SMLastHistoryModel.m
//  smplayer
//
//  Created by midoks on 2020/3/13.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMLastHistoryModel.h"
#import "SMVideoTime.h"

#define SM_LH_URL       @"SM_LH_URL"
#define SM_LH_NAME      @"SM_LH_NAME"
#define SM_LH_PLAYED    @"SM_LH_PLAYED"
#define SM_LH_ADDDATE   @"SM_LH_ADDDATE"
#define SM_LH_DURATION  @"SM_LH_DURATION"

@interface SMLastHistoryModel()<NSCoding>
{
    NSURL *url;
    NSString *name;
    
    BOOL played;
    NSDate *addedDate;
    
    SMVideoTime *duration;
    SMVideoTime *mpvProgress;
}
@end

@implementation SMLastHistoryModel

-(id)init:(NSURL *)url duration:(double)_duration {
    self->url = url;
    self->name = url.lastPathComponent;
    self->played = YES;
    self->addedDate = [NSDate  date];
    self->duration = [[SMVideoTime Instance] initTime:_duration];
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:url forKey:SM_LH_URL];
    [coder encodeObject:name forKey:SM_LH_NAME];
    [coder encodeBool:played forKey:SM_LH_PLAYED];
    [coder encodeObject:addedDate forKey:SM_LH_ADDDATE];
    [coder encodeObject:duration forKey:SM_LH_DURATION];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self->url =  [coder decodeObjectForKey:SM_LH_URL];
    self->name =  [coder decodeObjectForKey:SM_LH_NAME];
    self->played = [coder decodeBoolForKey:SM_LH_PLAYED];
    self->addedDate = [coder decodeObjectForKey:SM_LH_ADDDATE];
    self->duration = [coder decodeObjectForKey:SM_LH_DURATION];
    return self;
}

@end
