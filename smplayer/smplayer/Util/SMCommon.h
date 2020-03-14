//
//  SMCommon.h
//  smplayer
//
//  Created by midoks on 2020/2/26.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Notification Event Start
#define SM_NOTIF_FILELOADED @"NS_NOTIF_FileLoaded"


#define SM_HISTORY_FILE @"history.plist"


@interface SMCommon : NSObject

+(void)asyncCmd:(void(^)(void))cmd;

+(void)createDirIfNoExist:(NSURL *)url;
+(NSURL *)appSupportDirURL;
+(NSURL *)playHistoryURL;
@end

NS_ASSUME_NONNULL_END
