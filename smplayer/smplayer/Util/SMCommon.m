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

+(void)createDirIfNoExist:(NSURL *)url{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [url path];
    if (![fm fileExistsAtPath:path]){
        [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+(NSURL *)appSupportDirURL {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSURL *> *asPath = [fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;
    NSURL * appAsUrl = [asPath.firstObject URLByAppendingPathComponent:bundleID];
    
    [self createDirIfNoExist:appAsUrl];
    return appAsUrl;
}

+(NSURL *)playHistoryURL{
    return [[self appSupportDirURL] URLByAppendingPathComponent:SM_HISTORY_FILE];
}

@end
