//
//  AppDelegate.m
//  smplayer
//
//  Created by midoks on 2020/2/10.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "AppDelegate.h"
#import "SDragView.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    SDragView *sd = [[SDragView alloc] initWithFrame:self.window.frame];
    sd.wantsLayer = true;
    sd.layer.backgroundColor = [NSColor redColor].CGColor;
    sd.delegate = self;
    self.window.contentView = sd;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - SDragViewDelegate
// 接收单个文件
- (void)receivedFileUrl:(NSURL *)fileUrl{
    NSLog(@"%@", fileUrl);
}

// 接收到多个文件
//- (void)receivedFileUrlList:(NSArray< NSURL *> *)fileUrls{
//    NSLog(@"%@", fileUrls);
//}

// 鼠标双击事件
-(void)mouseDoubleClick:(NSEvent *)event{
    NSLog(@"%@",@"双击.....!");
    [self.window performZoom:nil];
}


#pragma mark - URL Schemes
- (void)application:(NSApplication *)application openURLs:(NSArray<NSURL *> *)urls{
//    [[NSAlert alertWithMessageText:@"URL Request"
//                     defaultButton:@"OK"
//                   alternateButton:nil
//                       otherButton:nil
//         informativeTextWithFormat:@"%@", urls] runModal];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setInformativeText:[NSString stringWithFormat:@"%@", urls]];
    [alert beginSheetModalForWindow:self.window
                  completionHandler:^(NSModalResponse returnCode){
                            //用户点击告警上面的按钮后的回调
                            NSLog(@"returnCode : %ld",(long)returnCode);
    }];
}


@end
