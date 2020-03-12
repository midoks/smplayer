//
//  SMCommon.m
//  smplayer
//
//  Created by midoks on 2020/2/26.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMCommon.h"

@implementation SMCommon


+(void)asyncCmd:(void(^)(void))cmd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        cmd();
    });
}

//-(void)creatre

@end
