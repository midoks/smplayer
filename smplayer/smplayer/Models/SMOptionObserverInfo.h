//
//  SMOptionObserverInfo.h
//  smplayer
//
//  Created by midoks on 2020/4/5.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MpvHelper.h"

typedef NSString* _Nullable (^SM_CALLBACK)(NSString * _Nonnull key);
NS_ASSUME_NONNULL_BEGIN

@interface SMOptionObserverInfo : NSObject

@property (nonatomic) NSString *key;
@property (nonatomic) SMUserOption option;
@property (nonatomic) NSString *name;
@property (nonatomic) SM_CALLBACK callback;

-(id)init:(NSString *)key
     name:(NSString *)name
   option:(SMUserOption)option
 callback:(NSString* (^)(NSString *key))callback;
@end

NS_ASSUME_NONNULL_END
