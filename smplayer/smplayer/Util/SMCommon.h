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

#pragma mark - Common
#define SM_AUTHOR_URL @"https://github.com/midoks/smplayer"

#pragma mark - Notification Event Start
#define SM_NOTIF_FILELOADED @"NS_NOTIF_FileLoaded"


#pragma mark - NSUserDefaults Config
#define SM_FILE_PATH @"SM_FILE_PATH"
#define SM_FILE_POS @"SM_FILE_POS"

#pragma mark - FILE NAME
#define SM_HISTORY_FILE @"history.plist"


typedef NS_ENUM(NSUInteger, SMAlertStyle) {
    SMAlertWindowSheetStyle = 0,
    SMAlertRunModelStyle = 1,
};

@interface SMCommon : NSObject

+(void)asyncCmd:(void(^)(void))cmd;
+(void)delayedRun:(float)t callback:(void(^)(void)) callback;

+(void)alert:(NSString *)info;
+(void)alert:(NSString *)msg
       info:(NSString *)info
      style:(NSAlertStyle)style
 delayedTime:(double)delayedTime;

+(void)quickPromptPanel:(NSString *)key
                 option:(SMAlertStyle)option
               callback:(void(^)(NSString *inputValue))callback;


+(BOOL)isMouseEvent:(NSEvent *)event views:(NSArray<NSView *> *)views;

+(NSMutableArray*)getSupportPlayFormat;
+(void)createDirIfNoExist:(NSURL *)url;

+(NSURL *)appSupportDirURL;
+(NSURL *)playHistoryURL;

#pragma mark - constraints
+(void)quickConstraints:(NSArray<NSString *>*)constraints view:(NSDictionary *)view;

#pragma mark - Size
+(CGFloat)sizeAspect:(NSSize)to;
+(NSSize)sizeGrow:(NSSize)from to:(NSSize)to;
+(NSSize)sizeShrink:(NSSize)from to:(NSSize)to;
+(NSRect)rectCentered:(NSRect)from to:(NSRect)to;
+(NSRect)resizeCentered:(NSRect)from to:(NSSize)to;
+(NSRect)sizeConstrain:(NSRect)from to:(NSRect)to;
+(NSSize)satisfyMinSizeWithSameAspectRatio:(NSSize)from to:(NSSize)to;
+(NSSize)satisfyMaxSizeWithSameAspectRatio:(NSSize)from to:(NSSize)to;

@end
NS_ASSUME_NONNULL_END
