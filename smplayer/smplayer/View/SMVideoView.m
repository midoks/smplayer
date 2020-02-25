//
//  SMVideoView.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavfilter/avfilter.h>
#include <libavfilter/buffersrc.h>
#include <libavfilter/buffersink.h>
#include <libavutil/opt.h>
#include <mpv/client.h>
#include <stdio.h>
#include <stdlib.h>

static void wakeup(void *);


static inline void check_error(int status)
{
    if (status < 0) {
        printf("%d:mpv API error: %s\n",status, mpv_error_string(status));
        exit(1);
    }
}


#import "SMVideoView.h"

@interface SMVideoView (){
    mpv_handle *mpv;
    dispatch_queue_t queue;
    NSView *wrapper;
}
@property int switchVoice;
@end

@implementation SMVideoView

static void wakeup(void *context) {
    SMVideoView *video = (__bridge SMVideoView *) context;
    [video readEvents];
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer =YES;
        self.layer.backgroundColor = [NSColor brownColor].CGColor;
        _switchVoice = 0;
        [self initUI];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSLog(@"%@", NSStringFromRect([NSApp mainWindow].contentView.frame));
    
    //监听鼠标事件
    [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:dirtyRect options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
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



- (void) mpv_stop
{
    if (mpv) {
        const char *args[] = {"stop", NULL};
        mpv_command(mpv, args);
    }
}

- (void) mpv_quit
{
    if (mpv) {
        const char *args[] = {"quit", NULL};
        mpv_command(mpv, args);
    }
}

-(void) initUI{
    wrapper = [[NSView alloc] initWithFrame:self.frame];
    [wrapper setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [self addSubview:wrapper];
    self->mpv = mpv_create();
    if (!self->mpv) {
        NSLog(@"%@", @"failed creating context");
        exit(-1);
    }
    
    int64_t wid = (intptr_t) self->wrapper;
    check_error(mpv_set_option(self->mpv, "wid", MPV_FORMAT_INT64, &wid));
    check_error(mpv_initialize(self->mpv));
}

-(void) initMenu{
    NSMenu *m = [[NSMenu alloc] initWithTitle:@"AMainMenu"];
    NSMenuItem *item = [m addItemWithTitle:@"Apple" action:nil keyEquivalent:@""];
    NSMenu *sm = [[NSMenu alloc] initWithTitle:@"Apple"];
    [m setSubmenu:sm forItem:item];
    [sm addItemWithTitle: @"mpv_command('stop')" action:@selector(mpv_stop) keyEquivalent:@"s"];
    [sm addItemWithTitle: @"mpv_command('quit')" action:@selector(mpv_quit) keyEquivalent:@"r"];
    [sm addItemWithTitle: @"quit" action:@selector(terminate:) keyEquivalent:@"q"];
    [NSApp setMenu:m];
    [NSApp activateIgnoringOtherApps:YES];
}

-(void) openVideo:(NSString *)path{
    //    [self initMenu];
    
    // Deal with MPV in the background.
    queue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        
        // Register to be woken up whenever mpv generates new events.
        mpv_set_wakeup_callback(self->mpv, wakeup, (__bridge void *) self);
        
        // Load the indicated file
        const char *cmd[] = {"loadfile", path.UTF8String, NULL};
        check_error(mpv_command(self->mpv, cmd));
    });
}

- (void) handleEvent:(mpv_event *)event
{
    switch (event->event_id) {
        case MPV_EVENT_SHUTDOWN: {
            mpv_detach_destroy(mpv);
            mpv = NULL;
            printf("event: shutdown\n");
            break;
        }
            
        case MPV_EVENT_LOG_MESSAGE: {
            struct mpv_event_log_message *msg = (struct mpv_event_log_message *)event->data;
            printf("[%s] %s: %s", msg->prefix, msg->level, msg->text);
        }
            
        case MPV_EVENT_VIDEO_RECONFIG: {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *subviews = [self->wrapper subviews];
                if ([subviews count] > 0) {
                    // mpv's events view
                    //                    NSView *eview = [self->wrapper subviews][0];
                    //                    [self->_window makeFirstResponder:eview];
                }
            });
        }
            
        default:
            printf("event: %s\n", mpv_event_name(event->event_id));
    }
}

- (void) readEvents
{
    dispatch_async(queue, ^{
        while (self->mpv) {
            mpv_event *event = mpv_wait_event(self->mpv, 0);
            if (event->event_id == MPV_EVENT_NONE){
                break;
            }
            [self handleEvent:event];
        }
    });
}



#pragma mark - 鼠标事件坚挺
//鼠标进入追踪区域
-(void)mouseEntered:(NSEvent *)event {
//    NSLog(@"mouseEntered =========");
}

//mouserEntered之后调用
-(void)cursorUpdate:(NSEvent *)event {
//    NSLog(@"cursorUpdate ==========");
    //更改鼠标光标样式
    [[NSCursor pointingHandCursor] set];
}

//鼠标退出追踪区域
-(void)mouseExited:(NSEvent *)event {
//    NSLog(@"mouseExited ========");
}

//鼠标左键按下
-(void)mouseDown:(NSEvent *)event {
    //event.clickCount 不是累计数。双击时调用mouseDown两次，clickCount第一次=1，第二次 = 2.
    if ([event clickCount] == 2) {
//        if (self.delegate) {
//            [self.delegate mouseDoubleClick:event];
//        }
        [[NSApp mainWindow] toggleFullScreen:event];
    }
    
//    NSLog(@"mouseDown ==== clickCount: %ld  buttonNumber: %ld",event.clickCount,event.buttonNumber);
    
//    self.layer.backgroundColor = [NSColor redColor].CGColor;
    
    //获取鼠标点击位置坐标：先获取event发生的window中的坐标，在转换成view视图坐标系坐标。
//    NSPoint eventLocation = [event locationInWindow];
//    NSPoint center = [self convertPoint:eventLocation fromView:nil];
    
//    NSLog(@"center: %@",NSStringFromPoint(center));
    
    //判断是否按下了Command键
//    if ([event modifierFlags] & NSEventModifierFlagCommand) {
//        [self setFrameRotation:[self frameRotation] + 90.0];
//        [self setNeedsDisplay:YES];
//        NSLog(@"按下了Command键 ---- ");
//    }
    
}

//鼠标左键起来
-(void)mouseUp:(NSEvent *)event {
//    NSLog(@"mouseUp ======");
//    self.layer.backgroundColor = [NSColor greenColor].CGColor;
}

//鼠标右键按下
- (void)rightMouseDown:(NSEvent *)event {
//    NSLog(@"rightMouseDown =======");
}

//鼠标右键起来
- (void)rightMouseUp:(NSEvent *)event {
//    NSLog(@"rightMouseUp ======= ");
}

//鼠标移动
- (void)mouseMoved:(NSEvent *)event {
//    NSLog(@"mouseMoved ========= ");
}

//鼠标按住左键进行拖拽
- (void)mouseDragged:(NSEvent *)event {
//    NSLog(@"mouseDragged ======== ");
}

//鼠标按住右键进行拖拽
- (void)rightMouseDragged:(NSEvent *)event {
//    NSLog(@"rightMouseDragged ======= ");
}

#pragma mark - Public Methods -
-(void)toggleVoice{
    if (mpv) {
        int data = _switchVoice ? 0 : 1;
        _switchVoice = data;
        mpv_set_property(mpv, "mute", MPV_FORMAT_FLAG, &data);
    }
}

-(void)stop{
    if (mpv) {
        int data = 1;
        mpv_set_property(mpv, "pause", MPV_FORMAT_FLAG, &data);
    }
}

-(void)start{
    if (mpv) {
        int data = 0;
        mpv_set_property(mpv, "pause", MPV_FORMAT_FLAG, &data);
    }
}



@end
