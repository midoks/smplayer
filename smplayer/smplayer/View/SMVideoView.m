//
//  SMVideoView.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#include <mpv/client.h>
#include <mpv/render_gl.h>
#include <stdio.h>
#include <stdlib.h>

#import <OpenGL/gl.h>
#import <Cocoa/Cocoa.h>

#import "SMVideoTime.h"
#import "SMVideoView.h"


@interface SMVideoView ()

@end

@implementation SMVideoView


static SMVideoView *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance:(NSRect)frame {
    dispatch_once(&_instance_once, ^{
        _instance = [[SMVideoView alloc] initWithFrame:frame];
    });
    return _instance;
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        _smLayer = [[SMVideoLayer alloc] init];
        _smLayer.delegate = self;
        self.layer = _smLayer;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:dirtyRect options:
                           NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
                           NSTrackingCursorUpdate |
                           NSTrackingActiveWhenFirstResponder |
                           NSTrackingActiveInKeyWindow |
                           NSTrackingActiveInActiveApp |
                           NSTrackingActiveAlways |
                           NSTrackingAssumeInside |
                           NSTrackingInVisibleRect |
                           NSTrackingEnabledDuringMouseDrag
                        owner:self userInfo:nil]];
    
    [self becomeFirstResponder];
}

-(void)openVideo:(NSString *)path{
    [self.smLayer openVideo:path];
}

-(void)videoStart:(SMVideoTime *)duration{
    if (self.delegate) {
        [self.delegate videoStart:duration];
    }
}
-(void)videoPos:(SMVideoTime *)pos{
    if (self.delegate) {
        [self.delegate videoPos:pos];
    }
}

////鼠标进入追踪区域
//-(void)mouseEntered:(NSEvent *)event {
//    NSLog(@"mouseEntered =========");
//}
//
////mouserEntered之后调用
//-(void)cursorUpdate:(NSEvent *)event {
//    NSLog(@"cursorUpdate ==========");
//    //更改鼠标光标样式
////    [[NSCursor pointingHandCursor] set];
//}
//
////鼠标退出追踪区域
//-(void)mouseExited:(NSEvent *)event {
//    NSLog(@"mouseExited ========");
//    if (self.delegate){
//        [self.delegate hiddenToolbar:YES];
//    }
//}
//
////鼠标左键按下
//-(void)mouseDown:(NSEvent *)event {
//    if ([event clickCount] == 2) {
//        [[NSApp mainWindow] toggleFullScreen:event];
//    }
//}
//
////鼠标左键起来
-(void)mouseUp:(NSEvent *)event {
    NSLog(@"mouseUp ======");
if (self.delegate){
          [self.delegate hiddenToolbar:NO];
      }
}
//
//鼠标右键按下
- (void)rightMouseDown:(NSEvent *)event {
    NSLog(@"rightMouseDown =======");
    
    if (self.delegate){
            [self.delegate hiddenToolbar:YES];
        }
}
//
////鼠标右键起来
//- (void)rightMouseUp:(NSEvent *)event {
//    NSLog(@"rightMouseUp ======= ");
//}
//
////鼠标移动
//- (void)mouseMoved:(NSEvent *)event {
//    NSLog(@"mouseMoved ========= ");
//}
//
////鼠标按住左键进行拖拽
//- (void)mouseDragged:(NSEvent *)event {
//    NSLog(@"mouseDragged ======== ");
//}
//
////鼠标按住右键进行拖拽
//- (void)rightMouseDragged:(NSEvent *)event {
//    NSLog(@"rightMouseDragged ======= ");
//}
//


@end
