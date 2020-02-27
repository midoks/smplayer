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

static void wakeup(void *);


static inline void check_error(int status)
{
    if (status < 0) {
        printf("%d:mpv API error: %s\n",status, mpv_error_string(status));
        exit(1);
    }
}

static void *get_proc_address(void *ctx, const char *name)
{
    CFStringRef symbolName = CFStringCreateWithCString(kCFAllocatorDefault, name, kCFStringEncodingASCII);
    void *addr = CFBundleGetFunctionPointerForName(CFBundleGetBundleWithIdentifier(CFSTR("com.apple.opengl")), symbolName);
    CFRelease(symbolName);
    return addr;
}

static void glupdate(void *ctx);



#import "SMVideoView.h"

@interface SMVideoView (){
    mpv_handle *mpv;
    dispatch_queue_t queue;
    NSView *wrapper;
    mpv_render_context *mpvGL;
}
@property NSTimer *syncPlayerTimer;
@property int switchVoice;
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
    //    self = [super initWithFrame:frame];
    self = [self initMpvGL:frame];
    if (self) {
        _switchVoice = 0;
        
        //        self.movableByWindowBackground = YES;
        //        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        
    }
    return self;
}

-(id) initMpvGL:(NSRect)frame{
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFADoubleBuffer,
        0
    };
    self = [super initWithFrame:frame pixelFormat:[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes]];
    
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        // swap on vsyncs
        GLint swapInt = 1;
        [[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval];
        [[self openGLContext] makeCurrentContext];
        self->mpvGL = nil;
    }
    return self;
}

-(void)fillBlack
{
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
}

-(void) drawRect{
    if (self->mpvGL) {
        mpv_render_param params[] = {
            // Specify the default framebuffer (0) as target. This will
            // render onto the entire screen. If you want to show the video
            // in a smaller rectangle or apply fancy transformations, you'll
            // need to render into a separate FBO and draw it manually.
            {MPV_RENDER_PARAM_OPENGL_FBO, &(mpv_opengl_fbo){
                .fbo = 0,
                .w = self.bounds.size.width,
                .h = self.bounds.size.height,
            }},
            // Flip rendering (needed due to flipped GL coordinate system).
            {MPV_RENDER_PARAM_FLIP_Y, &(int){1}},
            {0}
        };
        // See render_gl.h on what OpenGL environment mpv expects, and
        // other API details.
        mpv_render_context_render(self->mpvGL, params);
    } else{
        [self fillBlack];
    }
    
    [[self openGLContext] flushBuffer];
}


- (void)drawRect:(NSRect)dirtyRect {
    //    [super drawRect:dirtyRect];
    //    [self drawRect];
    
    //监听鼠标事件
    //    [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:dirtyRect options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
    //                           NSTrackingActiveWhenFirstResponder |
    //                           NSTrackingActiveInKeyWindow |
    //                           NSTrackingActiveInActiveApp |
    //                           NSTrackingActiveAlways |
    //                           NSTrackingAssumeInside |
    //                           NSTrackingInVisibleRect |
    //                           NSTrackingEnabledDuringMouseDrag
    //                        owner:self userInfo:nil]];
    //
    //    [self becomeFirstResponder];
    
}

-(void) initVideo {
    queue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL);
    mpv = mpv_create();
    if (!mpv) {
        NSLog(@"%@", @"failed creating context");
        exit(-1);
    }
    check_error(mpv_initialize(mpv));
    
    mpv_render_param params[] = {
        {MPV_RENDER_PARAM_API_TYPE, MPV_RENDER_API_TYPE_OPENGL},
        {MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &(mpv_opengl_init_params){
            .get_proc_address = get_proc_address,
        }},
        {0}
    };
    
    mpv_render_context *mpvGL;
    if (mpv_render_context_create(&mpvGL, mpv, params) < 0) {
        puts("failed to initialize mpv GL context");
        exit(1);
    }
    // pass the mpvGL context to our view
    self->mpvGL = mpvGL;
    
    mpv_render_context_set_update_callback(mpvGL, glupdate, (__bridge void *)self);
    
    //libmpv,gpu,opengl
    mpv_set_property_string(mpv, "vo", "libmpv");
    //    mpv_set_property_string(mpv, "keepaspect", "no");
    mpv_set_property_string(mpv, "gpu-hwdec-interop", "auto");
    mpv_request_log_messages(mpv, "warn");
    mpv_set_option_string(mpv, "input-default-bindings", "yes");
    
    //test
    mpv_set_property_string(mpv, "audio-device", "auto");
    
    //    mpv_set_property_string(mpv, "audio-spdif", "ac3,dts,dts-hd");
    //    mpv_set_option_string(mpv, "config", "yes");
    //    mpv_set_option_string(mpv, "osxbundle", [[NSBundle mainBundle] resourcePath].UTF8String);
    //    mpv_observe_property(mpv, 1 ,"window-scale", MPV_FORMAT_DOUBLE);
    
    //    NSLog(@"path:%@",[[NSBundle mainBundle] resourcePath]);
    
    
}

-(void)openVideo:(NSString *)path{
    
    // Deal with MPV in the background.
    
    dispatch_async(queue, ^{
        // Register to be woken up whenever mpv generates new events.
        mpv_set_wakeup_callback(self->mpv, wakeup, (__bridge void *) self);
    });
    
    // Load the indicated file
    const char *cmd[] = {"loadfile", path.UTF8String, NULL};
    check_error(mpv_command(self->mpv, cmd));
}


static void wakeup(void *context) {
    SMVideoView *video = (__bridge SMVideoView *) context;
    [video readEvents];
}

-(void)readEvents {
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

static void glupdate(void *ctx)
{
    SMVideoView *video = (__bridge SMVideoView *)ctx;
    // I'm still not sure what the best way to handle this is, but this works.
    dispatch_async(dispatch_get_main_queue(), ^{
        [video drawRect];
    });
}

-(void)handleEvent:(mpv_event *)event
{
    switch (event->event_id) {
        case MPV_EVENT_SHUTDOWN: {
            mpv_render_context_free(mpvGL);
            mpv_detach_destroy(mpv);
            mpv = NULL;
            NSLog(@"event: shutdown");
            break;
        }
        case MPV_EVENT_FILE_LOADED:{
            double width = [self mpvGetDouble:@"width"];
            double height = [self mpvGetDouble:@"height"];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSApp mainWindow] setFrame:NSMakeRect(0, 0, width, height) display:YES];
            });
            
            break;
        }
        case MPV_EVENT_LOG_MESSAGE: {
            struct mpv_event_log_message *msg = (struct mpv_event_log_message *)event->data;
            printf("[%s] %s: %s", msg->prefix, msg->level, msg->text);
            break;
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


#pragma mark - 鼠标事件监听
//鼠标进入追踪区域
-(void)mouseEntered:(NSEvent *)event {
    //    NSLog(@"mouseEntered =========");
}

//mouserEntered之后调用
-(void)cursorUpdate:(NSEvent *)event {
    //    NSLog(@"cursorUpdate ==========");
    //更改鼠标光标样式
    //    [[NSCursor pointingHandCursor] set];
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
    NSLog(@"mouseMoved ========= ");
}

//鼠标按住左键进行拖拽
- (void)mouseDragged:(NSEvent *)event {
    //    NSLog(@"mouseDragged ======== ");
}

//鼠标按住右键进行拖拽
- (void)rightMouseDragged:(NSEvent *)event {
    //    NSLog(@"rightMouseDragged ======= ");
}

#pragma mark - MPV Private Methods
-(int)mpvGetInt:(NSString *)name {
    int64_t data;
    mpv_get_property(mpv, name.UTF8String, MPV_FORMAT_INT64, &data);
    return (int)data;
}

-(double)mpvGetDouble:(NSString *)name {
    int64_t data;
    mpv_get_property(mpv, name.UTF8String, MPV_FORMAT_INT64, &data);
    return (double)data;
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
        [self clearGLContext];
    }
}





@end
