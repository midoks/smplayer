//
//  SMCommon.h
//  smplayer
//
//  Created by midoks on 2020/2/26.
//  Copyright © 2020 midoks. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#include <mach-o/dyld.h>

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Notification Event Start
#define SM_NOTIF_FILELOADED @"NS_NOTIF_FileLoaded"


#pragma mark - NSUserDefaults Config
#define SM_FILE_PATH @"SM_FILE_PATH"
#define SM_FILE_POS @"SM_FILE_POS"


#define SM_HISTORY_FILE @"history.plist"



@interface SMCommon : NSObject
+(void)delayedRun:(float)t callback:(void(^)(void)) callback;

+(void)alert:(NSString *)info;
+(void)alert:(NSString *)msg
       info:(NSString *)info
      style:(NSAlertStyle)style
 delayedTime:(double)delayedTime;

+(void)asyncCmd:(void(^)(void))cmd;

+(NSMutableArray*)getSupportPlayFormat;
+(void)createDirIfNoExist:(NSURL *)url;

+(NSURL *)appSupportDirURL;
+(NSURL *)playHistoryURL;

#pragma mark - constraints
+(void)quickConstraints:(NSArray<NSString *>*)constraints view:(NSDictionary *)view;
@end

NS_ASSUME_NONNULL_END
