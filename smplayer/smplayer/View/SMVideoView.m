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

static void wakeup(void *);
static void glupdate(void *ctx);

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
    return addr;
}

@interface SMVideoView (){
    mpv_handle *mpv;
    dispatch_queue_t queue;
    NSView *wrapper;
    mpv_render_context *mpvGL;
}
@property (nonatomic, weak) NSTimer *asyncPlayerTimer;
@property int switchVoice;
@property double videoDuration;
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
    self = [self initMpvGL:frame];
    if (self) {
        _switchVoice = 0;
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        
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
        // swap on vsyncs
        GLint swapInt = 0;
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

-(void) drawRectGL {
    if (self->mpvGL) {
        mpv_render_param params[] = {
            {MPV_RENDER_PARAM_OPENGL_FBO, &(mpv_opengl_fbo){
                .fbo = 0,
                .w = self.bounds.size.width,
                .h = self.bounds.size.height,
            }},
            {MPV_RENDER_PARAM_FLIP_Y, &(int){1}},
            {0}
        };
        
        mpv_render_context_render(self->mpvGL, params);
    } else{
        [self fillBlack];
    }
    
    [[self openGLContext] flushBuffer];
}


- (void)drawRect:(NSRect)dirtyRect {
    [self drawRectGL];
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
    
    mpv_render_context_set_update_callback(self->mpvGL, glupdate, (__bridge void *)self);
    
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
        [video drawRectGL];
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
            [self fileLoad];
            break;
        }
        case MPV_EVENT_LOG_MESSAGE: {
            struct mpv_event_log_message *msg = (struct mpv_event_log_message *)event->data;
            printf("[%s] %s: %s", msg->prefix, msg->level, msg->text);
            break;
        }
        case MPV_EVENT_VIDEO_RECONFIG: {
            dispatch_async(dispatch_get_main_queue(), ^{
                // NSArray *subviews = [self->wrapper subviews];
                // if ([subviews count] > 0) {
                // mpv's events view
                //      NSView *eview = [self->wrapper subviews][0];
                //     [self->_window makeFirstResponder:eview];
                // }
            });
        }
        default:{
            NSLog(@"event: %s\n", mpv_event_name(event->event_id));
        }
    }
}

#pragma mark - MPV Event Methods
-(void)fileLoad{
    
    NSLog(@"MPV Event Methods - fileLoad start!");
    
    double width = [self mpvGetDouble:@"width"];
    double height = [self mpvGetDouble:@"height"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSApp mainWindow] setFrame:NSMakeRect(100, 100, width, height) display:YES];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(videoDurationAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        self.asyncPlayerTimer  = timer;
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate) {
            self->_videoDuration = [self mpvGetDouble:@"duration"];
            [self.delegate videoStart:[[SMVideoTime alloc] initTime:self->_videoDuration]];
        }
    });
}

-(void)videoDurationAction{
    if (self.delegate) {
        double pos = [self mpvGetDouble:@"time-pos"];
        if (pos>_videoDuration){
            pos = _videoDuration;
        }
        [self.delegate videoPos:[[SMVideoTime alloc] initTime:pos]];
    }
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
-(void)mpvCmd{
    
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

-(void)seek:(const char *)second {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->mpv) {
            const char *args[] = {"seek", second, "absolute+exact", NULL};
            mpv_command(self->mpv, args);
        }
    });
}

@end
