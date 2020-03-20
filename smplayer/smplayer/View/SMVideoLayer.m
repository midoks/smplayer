//
//  SMVideoLayer.m
//  smplayer
//
//  Created by midoks on 2020/3/6.
//  Copyright © 2020 midoks. All rights reserved.
//
#include <mpv/client.h>
#include <mpv/render.h>
#include <mpv/render_gl.h>

@import OpenGL.GL;
@import OpenGL.GL3;

#import "SMVideoTime.h"
#import "SMVideoLayer.h"
#import "SMCommon.h"
#import "SMLastHistory.h"


static void wakeup(void *);
static void *get_proc_address(void *ctx, const char *name);

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


@interface SMVideoLayer()
{
    CGLContextObj _cglContext;
    CGLPixelFormatObj _cglPixelFormat;
    
    mpv_handle *mpv;
    mpv_render_context *_mpv_render_context;
}

@property (nonatomic, strong) NSLock* uninitLock;

@property (nonatomic, weak) NSTimer *asyncPlayerTimer;
@property BOOL switchVoice;
@property BOOL switchVideo;
@property double videoDuration;
@property double videoPos;
@property NSString *currentPath;
@end

@implementation SMVideoLayer

-(id)init{
    self = [super init];
    if (self) {
        [self setAsynchronous:NO];
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        
        _switchVoice = NO;
        _switchVideo = NO;
        
        _cglPixelFormat = [self copyCGLPixelFormatForDisplayMask:0];
        if (!_cglPixelFormat) {
            NSLog(@"Failed to create CGLPixelFormatObj");
            return nil;
        }
        CGLError err = CGLCreateContext(_cglPixelFormat, nil, &_cglContext);
        if (!_cglContext) {
            NSLog(@"Failed to create CGLContextObj %d", err);
            return nil;
        }
        GLint i = 1;
        CGLSetParameter(_cglContext, kCGLCPSwapInterval, &i);
        CGLSetCurrentContext(_cglContext);
        
        [self initMPV];
        [self initVideoRender];
    }
    return self;
}

- (CGLPixelFormatObj)copyCGLPixelFormatForDisplayMask:(uint32_t)mask {
    CGLPixelFormatAttribute att1[] = {
        kCGLPFADoubleBuffer,
        kCGLPFAOpenGLProfile,  (CGLPixelFormatAttribute)kCGLOGLPVersion_3_2_Core,
        kCGLPFAAccelerated,
        kCGLPFAAllowOfflineRenderers,
        0
    };
    
    
    CGLPixelFormatAttribute att2[] = {
        kCGLPFADoubleBuffer,
        kCGLPFAOpenGLProfile,  (CGLPixelFormatAttribute)kCGLOGLPVersion_3_2_Core,
        kCGLPFAAllowOfflineRenderers,
        0
    };
    
    
    CGLPixelFormatAttribute att3[] = {
        kCGLPFADoubleBuffer,
        kCGLPFAOpenGLProfile,  (CGLPixelFormatAttribute)kCGLOGLPVersion_3_2_Core,
        kCGLPFAAllowOfflineRenderers,
        0
    };
    
    
    CGLPixelFormatObj pix = NULL;
    GLint npix = 0;
    
    if (pix==NULL){
        CGLError error = CGLChoosePixelFormat(att1, &pix, &npix);
        if (error != kCGLNoError) {
            NSLog(@"ddd:%d", error);
        }
    }
    
    if (pix==NULL){
        CGLError error = CGLChoosePixelFormat(att2, &pix, &npix);
        if (error != kCGLNoError) {
            NSLog(@"ddd:%d", error);
        }
    }
    
    if (pix==NULL){
        CGLError error = CGLChoosePixelFormat(att3, &pix, &npix);
        if (error != kCGLNoError) {
            NSLog(@"ddd:%d", error);
        }
    }
    return pix;
}


- (BOOL)canDrawInCGLContext:(CGLContextObj)ctx pixelFormat:(CGLPixelFormatObj)pf forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts {
    return (_mpv_render_context != nil);
}

- (void)drawInCGLContext:(CGLContextObj)ctx pixelFormat:(CGLPixelFormatObj)pf forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts {
    [_uninitLock lock];
    _draw_frame(self);
    [_uninitLock unlock];
}

- (CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pf {
    return _cglContext;
}


static inline void _draw_frame(SMVideoLayer *obj) {
    
    static GLint dims[] = { 0, 0, 0, 0 };
    glGetIntegerv(GL_VIEWPORT, dims);
    
    GLint i = 0;
    glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING, &i);
    
    if (i) {
    }
    
    mpv_render_param params[] = {
        {MPV_RENDER_PARAM_OPENGL_FBO, &(mpv_opengl_fbo){
            .fbo = i,
            .w = obj.frame.size.width,
            .h = obj.frame.size.height,
        }},
        {MPV_RENDER_PARAM_FLIP_Y, &(int){1}},
        {0}
    };
    
    mpv_render_context_render(obj->_mpv_render_context, params);
    CGLFlushDrawable(obj->_cglContext);
}

-(void) display {
    [super display];
    [CATransaction flush];
}

-(void)initMPV{
    _queue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL);
    mpv = mpv_create();
    if (!mpv) {
        NSLog(@"%@", @"failed creating context");
        exit(-1);
    }
    
    //libmpv,gpu,opengl
    mpv_set_property_string(mpv, "vo", "libmpv");
    mpv_set_property_string(mpv, "keepaspect", "yes");
    mpv_set_property_string(mpv, "gpu-hwdec-interop", "auto");
    
    check_error( mpv_set_option_string(mpv, "hwdec", "videotoolbox"));
#ifdef ENABLE_LEGACY_GPU_SUPPORT
    check_error( mpv_set_option_string(mpv, "hwdec-image-format", "uyvy422"));
#endif
    mpv_request_log_messages(mpv, "warn");
    check_error(mpv_initialize(mpv));
}

-(void)initVideoRender{
    mpv_render_param params[] = {
        {MPV_RENDER_PARAM_API_TYPE, MPV_RENDER_API_TYPE_OPENGL},
        {MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &(mpv_opengl_init_params){
            .get_proc_address = get_proc_address,
            .get_proc_address_ctx = NULL,
            .extra_exts = NULL,
        }},
        {0}
    };
    
    if (mpv_render_context_create(&_mpv_render_context, mpv, params) < 0) {
        puts("failed to initialize mpv GL context");
        exit(1);
    }
    
    mpv_render_context_set_update_callback(_mpv_render_context, render_context_callback, (__bridge void *)self);
    
}

-(void)openVideo:(NSString *)path{
    _currentPath = path;
    mpv_set_wakeup_callback(self->mpv, wakeup, (__bridge void *) self);
    const char *cmd[] = {"loadfile", path.UTF8String, NULL};
    check_error(mpv_command(self->mpv, cmd));
}

-(void)closeVideo{
    
    [self stop];
    [[NSUserDefaults standardUserDefaults] setObject:self->_currentPath forKey:SM_FILE_PATH];
    [[NSUserDefaults standardUserDefaults] setDouble:_videoPos forKey:SM_FILE_POS];
}


static void wakeup(void *context) {
    SMVideoLayer *video = (__bridge SMVideoLayer *) context;
    [video readEvents];
}

-(void)readEvents {
    dispatch_async(_queue, ^{
        while (self->mpv) {
            mpv_event *event = mpv_wait_event(self->mpv, 0);
            if (event->event_id == MPV_EVENT_NONE){
                break;
            }
            [self handleEvent:event];
        }
    });
}

static void render_context_callback(void *ctx) {
    SMVideoLayer *obj = (__bridge id)ctx;
    dispatch_async(dispatch_get_main_queue(), ^{
        [obj display];
    });
}


-(void)handleEvent:(mpv_event *)event
{
    switch (event->event_id) {
        case MPV_EVENT_SHUTDOWN: {
            if (mpv){
//                mpv_detach_destroy(mpv);
                mpv = NULL;
            }
            NSLog(@"event-MPV_EVENT_SHUTDOWN: shutdown");
            break;
        }
        case MPV_EVENT_FILE_LOADED:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fileLoad];
            });
            break;
        }
        case MPV_EVENT_PROPERTY_CHANGE:{
            NSLog(@"MPV_EVENT_PROPERTY_CHANGE");
            break;
        }
        case MPV_EVENT_LOG_MESSAGE: {
            struct mpv_event_log_message *msg = (struct mpv_event_log_message *)event->data;
            printf("[%s] %s: %s", msg->prefix, msg->level, msg->text);
            break;
        }
        case MPV_EVENT_VIDEO_RECONFIG: {
            dispatch_async(dispatch_get_main_queue(), ^{
            });
            break;
        }
        default:{
            NSLog(@"event-default: %s\n", mpv_event_name(event->event_id));
            break;
        }
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

-(BOOL)getFlag:(NSString *)name{
    int64_t data;
    NSLog(@"getFlag:%@", name);
    mpv_get_property(mpv, name.UTF8String, MPV_FORMAT_INT64, &data);
    NSLog(@"getFlag:%lld", data);
    return data > 0;
}


-(void)fileLoad{
    _switchVideo = YES;
    
    double w = [self mpvGetDouble:@"width"];
    double h = [self mpvGetDouble:@"height"];
    
    
    [[NSApp mainWindow] setFrame:NSMakeRect(0, 0, w, h) display:YES];
    [[NSApp mainWindow] center];
    
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(videoDurationAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.asyncPlayerTimer  = timer;
    
    if (self.videoDelegate) {
        self->_videoDuration = [self mpvGetDouble:@"duration"];
        [self.videoDelegate videoStart:[[SMVideoTime alloc] initTime:self->_videoDuration]];
    }
    

    NSURL *urlFile = [NSURL fileURLWithPath:self->_currentPath isDirectory:NO];
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:urlFile];
    [[NSNotificationCenter defaultCenter] postNotificationName:SM_NOTIF_FILELOADED object:nil userInfo:nil];
    
//    [[SMLastHistory Instance] add:urlFile duration:2.0];
}

-(void)videoDurationAction{
    if (self.videoDelegate) {
        double pos = [self mpvGetDouble:@"time-pos"];
        if (pos>_videoDuration){
            pos = _videoDuration;
        }
        _videoPos = pos;
        [[SMLastHistory Instance] add:[NSURL fileURLWithPath:self->_currentPath isDirectory:NO] duration:_videoPos];
        [self.videoDelegate videoPos:[[SMVideoTime alloc] initTime:_videoPos]];
    }
}


#pragma mark - Public Methods -
-(void)toggleVideo {
    if(mpv){
        _switchVideo ? [self stop] : [self resume];
    }
}

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
        _switchVideo = NO;
        int data = 1;
        mpv_set_property(mpv, "pause", MPV_FORMAT_FLAG, &data);
    }
}

-(void)resume{
    if(![self getFlag:@"eof-reached"]){
        NSLog(@"eof-reached");
        NSString *d = @"0";
        [self seek:d.UTF8String];
    }
    [self start];
}

-(void)start{
    if (mpv) {
        _switchVideo = YES;
        int data = 0;
        mpv_set_property(mpv, "pause", MPV_FORMAT_FLAG, &data);
    }
}

-(void)quit{
    _switchVideo = NO;
    if (mpv) {
        const char *args[] = {"quit", NULL};
        mpv_command(mpv, args);
    }
}
-(void)windowScale:(double)scale{
    if (self->mpv) {
        double data = scale;
        mpv_set_property(mpv, "window-scale", MPV_FORMAT_DOUBLE, &data);
    }
}

-(void)seek:(const char *)second {
    if (self->mpv) {
        const char *args[] = {"seek", second, "exact", NULL};
        mpv_command(self->mpv, args);
    }
}

-(void)seekWithRelative:(const char *)second {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stop];
        if (self->mpv) {
            const char *args[] = {"seek", second, "relative+exact", NULL};
            mpv_command(self->mpv, args);
        }
        [self resume];
    });
}

-(void)seekWithAbsolute:(const char *)second {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->mpv) {
            const char *args[] = {"seek", second, "absolute+exact", NULL};
            mpv_command(self->mpv, args);
        }
    });
}

@end
