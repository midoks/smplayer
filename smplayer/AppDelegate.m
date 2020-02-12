//
//  AppDelegate.m
//  smplayer
//
//  Created by midoks on 2020/2/10.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayerUIView.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) PlayerUIView *player;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // 窗口可以拖拽
    self.window.movableByWindowBackground = YES;
    
    self.player = [[PlayerUIView alloc] initWithFrame:self.window.frame];
    self.player.delegate = self;
    self.window.contentView = self.player;
    
    
    NSButton *b = [[NSButton alloc] initWithFrame:NSMakeRect(self.window.frame.size.width-40, 0, 25, 20)];
    [b setBezelStyle:NSBezelStyleDisclosure];
    [b setButtonType:NSButtonTypeMomentaryPushIn];
    [b setImage:[NSImage imageNamed:@"goto"]];
    [b setToolTip:@"提示1"];
    
    
    NSLog(@"%@",self.window.contentView.superview.subviews) ;
    NSArray *subviews = self.window.contentView.superview.subviews;
    for (NSView *view in subviews) {
        if ([view isKindOfClass:NSClassFromString(@"NSTitlebarContainerView")]) {
            [view addSubview:b];
//            [view setFrame:NSMakeRect(view.frame.origin.x, view.frame.origin.y-10, view.frame.size.width, view.frame.size.height+10)];
        }
    }
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
//    [self.window performZoom:event];
    
    //将titleBar和下面的view合并到一起
//    self.window.styleMask = self.window.styleMask | NSWindowStyleMaskFullSizeContentView;
    //设置标题栏透明
//    self.window.titlebarAppearsTransparent = YES;
    //隐藏窗口标题
//    self.window.titleVisibility = NSWindowTitleHidden;
    
    [self.window toggleFullScreen:event];
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
