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
        _switchVoice = 0;
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
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

-(void) initVideo {
//    wrapper = [[NSView alloc] initWithFrame:self.frame];
//    [wrapper setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
//    [self addSubview:wrapper];
//    int64_t wid = (intptr_t) self->wrapper;
    
    mpv = mpv_create();
    if (!mpv) {
        NSLog(@"%@", @"failed creating context");
        exit(-1);
    }
    
    check_error(mpv_initialize(mpv));
    
    //libmpv,gpu
//    mpv_set_property_string(mpv, "vo", "libmpv");
//    mpv_set_property_string(mpv, "keepaspect", "no");
//    mpv_set_property_string(mpv, "gpu-hwdec-interop", "auto");
    mpv_request_log_messages(mpv, "warn");

    int64_t wid = (intptr_t) _instance;
    check_error(mpv_set_option(mpv, "wid", MPV_FORMAT_INT64, &wid));
    
    
}

-(void)openVideo:(NSString *)path{
    
    // Deal with MPV in the background.
    queue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        // Register to be woken up whenever mpv generates new events.
        mpv_set_wakeup_callback(self->mpv, wakeup, (__bridge void *) self);
    });
    
    // Load the indicated file
    const char *cmd[] = {"loadfile", path.UTF8String, NULL};
    check_error(mpv_command(self->mpv, cmd));
}

- (void)handleEvent:(mpv_event *)event
{
    switch (event->event_id) {
        case MPV_EVENT_SHUTDOWN: {
            mpv_detach_destroy(mpv);
            mpv = NULL;
            NSLog(@"event: shutdown");
            break;
        }
            
        case MPV_EVENT_LOG_MESSAGE: {
            struct mpv_event_log_message *msg = (struct mpv_event_log_message *)event->data;
            printf("[%s] %s: %s", msg->prefix, msg->level, msg->text);
        }
            
        case MPV_EVENT_VIDEO_RECONFIG: {
            dispatch_async(dispatch_get_main_queue(), ^{
//                NSArray *subviews = [self->wrapper subviews];
//                if ([subviews count] > 0) {
                    // mpv's events view
                    // NSView *eview = [self->wrapper subviews][0];
                    // [self->_window makeFirstResponder:eview];
//                }
            });
        }
        default:{
            NSLog(@"event: %s\n", mpv_event_name(event->event_id));
        }
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
    if ([event clickCount] == 2) {
        [[NSApp mainWindow] toggleFullScreen:event];
    }
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

-(void)setVoice:(double)value{
    if (mpv) {
        double data = value;
        mpv_set_property_async(mpv, 0, "volume", MPV_FORMAT_DOUBLE, &data);
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

-(void)quit{
    if (mpv) {
        const char *args[] = {"quit", NULL};
        mpv_command(mpv, args);
    }
}





@end
