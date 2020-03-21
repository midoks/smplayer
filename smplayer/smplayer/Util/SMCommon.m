//
//  SMCommon.m
//  smplayer
//
//  Created by midoks on 2020/2/26.
//  Copyright © 2020 midoks. All rights reserved.
//
#import "SMCommon.h"

@implementation SMCommon


+(void)delayedRun:(float)t
         callback:(void(^)(void)) callback
{
    double delayInSeconds = t;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        callback();
    });
}

+(void)alert:(NSString *)info{
    [self alert:NSLocalizedString(@"alert.notice", nil) info:info style:NSAlertStyleInformational delayedTime:3.0];
}

+(void)alert:(NSString *)msg
        info:(NSString *)info
       style:(NSAlertStyle)style
 delayedTime:(double)delayedTime  {
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:msg];
    [alert setInformativeText:info];
    [alert setAlertStyle:style];
    [alert runModal];
    
    if (delayedTime>0){
        [self delayedRun:delayedTime callback:^{
            [alert.window close];
        }];
    }
}


+(void)asyncCmd:(void(^)(void))cmd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        cmd();
    });
}

+(BOOL)isMouseEvent:(NSEvent *)event views:(NSArray<NSView *> *)views
{
    BOOL result = NO;
    for (NSView *v in views) {
        NSPoint p = [v convertPoint:[event locationInWindow] fromView:NULL];
        result = [v mouse:p inRect:v.bounds];
        if (result){
            return result;
        }
    }
    return result;
}

+(void)createDirIfNoExist:(NSURL *)url{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [url path];
    if (![fm fileExistsAtPath:path]){
        [fm createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
    }
}


+(NSMutableArray*)getSupportPlayFormat{
    NSMutableArray *formatList = [[NSMutableArray alloc] init];
    
    NSArray *list = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDocumentTypes"];
    for (int i = 0 ; i<[list count]; i++) {
        NSArray *format = [list[i] objectForKey:@"CFBundleTypeExtensions"];
        [formatList addObjectsFromArray:format];
    }
    
    return formatList;
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

#pragma mark - constraints
+(void)quickConstraints:(NSArray<NSString *>*)constraints view:(NSDictionary *)view {
    for (NSString * c in constraints) {
        NSArray *cc = [NSLayoutConstraint constraintsWithVisualFormat:c options:0 metrics:nil views:view];
        [NSLayoutConstraint activateConstraints:cc];
    }
}


@end
