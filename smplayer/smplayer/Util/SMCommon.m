//
//  SMCommon.m
//  smplayer
//
//  Created by midoks on 2020/2/26.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SMCommon.h"

@implementation SMCommon

+(void)asyncCmd:(void(^)(void))cmd
{
    dispatch_async(dispatch_get_main_queue(), ^{
        cmd();
    });
}

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

#pragma mark - Panel
+(void)quickPromptPanel:(NSString *)key
            option:(SMAlertStyle)option
               callback:(void(^)(NSString *inputValue))callback
{
    NSString *titleKey = [NSString stringWithFormat:@"alert.%@.title", key];
    NSString *msgKey = [NSString stringWithFormat:@"alert.%@.message", key];
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = NSLocalizedString(titleKey, nil);
    alert.informativeText = NSLocalizedString(msgKey, nil);

    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 240, 24)];
    input.lineBreakMode = NSLineBreakByClipping;
    input.usesSingleLineMode = YES;

    alert.accessoryView = input;
    [alert addButtonWithTitle:NSLocalizedString(@"common.ok", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"common.cancel", nil)];
    alert.window.initialFirstResponder = input;
    
    if (option == SMAlertWindowSheetStyle){
        [alert beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSModalResponse returnCode) {
            callback([input stringValue]);
        }];
    } else {
        if ([alert runModal]){
            callback([input stringValue]);
        }
    }
}

+(void)quickOpenPanel:(NSString *)title
                chooseDir:(BOOL)chooseDir
                  dir:(NSURL * _Nonnull )dir
             callback:(void(^)(NSURL *url))callback
{
    NSOpenPanel *panel = [[NSOpenPanel alloc] init];
    panel.title = title;
    panel.canCreateDirectories = NO;
    panel.canChooseFiles = !chooseDir;
    panel.canChooseDirectories = chooseDir;
    panel.allowsMultipleSelection = NO;
    panel.level =  NSModalPanelWindowLevel;
    
    if (!dir){
        panel.directoryURL = dir;
    }
    
    if([panel runModal]){
        callback([panel URL]);
    }
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

#pragma mark - Size

+(CGFloat)sizeAspect:(NSSize)to{
    assert(to.width !=0 && to.height != 0);
    return to.width/to.height;
}

+(NSSize)sizeGrow:(NSSize)from to:(NSSize)to {
    if (from.width == 0 || from.height == 0){
        return from;
    }
    CGFloat fromAspect = [self sizeAspect:from];
    CGFloat toAspect = [self sizeAspect:to];
    if (fromAspect > toAspect){
        return NSMakeSize(to.height*fromAspect, to.height);
    }
    return NSMakeSize(to.width, to.height/fromAspect);
}

+(NSSize)sizeShrink:(NSSize)from to:(NSSize)to{
    if (to.width == 0 || to.height == 0){
        return to;
    }
    CGFloat fromAspect = [self sizeAspect:from];
    CGFloat toAspect = [self sizeAspect:to];
    if (fromAspect < toAspect){
        return NSMakeSize(to.height*fromAspect, to.height);
    }
    return NSMakeSize(to.width, to.width/fromAspect);
}

+(NSSize)satisfyMinSizeWithSameAspectRatio:(NSSize)from to:(NSSize)to{
    if (from.width >= to.width && from.height >= to.height){
        return from;
    }
    return [self sizeGrow:from to:to];
}

+(NSSize)satisfyMaxSizeWithSameAspectRatio:(NSSize)from to:(NSSize)to{
    if (from.width <= to.width && from.height <= to.height){
        return from;
    }
    return [self sizeShrink:from to:to];
}

+(NSRect)rectCentered:(NSRect)from to:(NSRect)to{
    return NSMakeRect(
            (to.size.width-from.size.width)/2,
            (to.size.height-from.size.height)/2,
            from.size.width,
            from.size.height
    );
}

+(NSRect)resizeCentered:(NSRect)from to:(NSSize)to{
    return NSMakeRect(
            from.origin.x - (to.width-from.size.width)/2,
            from.origin.y - (to.height-from.size.height)/2,
            to.width,
            to.height
    );
}

+(NSRect)sizeConstrain:(NSRect)from to:(NSRect)to
{
    NSSize newSize = from.size;
    if (newSize.width>to.size.width || newSize.height> to.size.height){
        newSize = [self sizeShrink:from.size to:to.size];
    }
    
    CGPoint newOrgin = from.origin;
    if (newOrgin.x < to.origin.x) {
        newOrgin.x = to.origin.x;
    }
    
    if (newOrgin.y < to.origin.y ){
        newOrgin.y = to.origin.y;
    }
    
    if (newOrgin.x+from.size.width > to.origin.x + to.size.width){
        newOrgin.x = to.origin.x + to.size.width - from.size.width;
    }
    
    if (newOrgin.y + from.size.height < to.origin.y + to.size.height){
        newOrgin.y = to.origin.y + to.size.height - from.size.height;
    }
    return NSMakeRect(newOrgin.x, newOrgin.y, newSize.width, newSize.height);
}



+(NSString *)md5:(NSString *)toStr{
    const char *cStr = [toStr UTF8String];
//    unsigned char result[16];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3],
          result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11],
          result[12], result[13], result[14], result[15]
    ];

}

@end
