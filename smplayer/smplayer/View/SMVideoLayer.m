//
//  SMVideoLayer.m
//  smplayer
//
//  Created by midoks on 2020/3/6.
//  Copyright © 2020 midoks. All rights reserved.
//


#import "SMVideoTime.h"
#import "SMCommon.h"
#import "SMCore.h"
#import "SMLastHistory.h"

#import "SMVideoLayer.h"

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
    mpv_render_context *sm_render_context;
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
//    NSLog(@"dddd");
//    [[[SMCore Instance] player].uninitLock lock];
    return (sm_render_context != nil);
}

- (void)drawInCGLContext:(CGLContextObj)ctx pixelFormat:(CGLPixelFormatObj)pf forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts {
//    [_uninitLock lock];
    
    [[[SMCore Instance] player].uninitLock lock];
//    NSLog(@"lock2");
    draw_frame(self);
//    [self drawFrame];
//    [_uninitLock unlock];
    
    [[[SMCore Instance] player].uninitLock unlock];
}

- (CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pf {
    return _cglContext;
}


-(void)drawFrame{
    static GLint dims[] = { 0, 0, 0, 0 };
    glGetIntegerv(GL_VIEWPORT, dims);
    
    GLint i = 0;
    glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING, &i);
    
    mpv_render_param params[] = {
        {MPV_RENDER_PARAM_OPENGL_FBO, &(mpv_opengl_fbo){
            .fbo = i,
            .w = self.frame.size.width,
            .h = self.frame.size.height,
        }},
        {MPV_RENDER_PARAM_FLIP_Y, &(int){1}},
        {0}
    };
    
    mpv_render_context_render(sm_render_context, params);
    CGLFlushDrawable(_cglContext);
}

static inline void draw_frame(SMVideoLayer *obj) {
    
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
    
    mpv_render_context_render(obj->sm_render_context, params);
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
    
    if (mpv_render_context_create(&sm_render_context, mpv, params) < 0) {
        puts("failed to initialize mpv GL context");
        exit(1);
    }
    mpv_render_context_set_update_callback(sm_render_context, render_context_callback, (__bridge void *)self);
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
//            NSLog(@"event-default: %s\n", mpv_event_name(event->event_id));
            break;
        }
    }
}


#pragma mark - MPV Init Methods



#pragma mark - MPV Public Methods
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

-(BOOL)mpvGetFlag:(NSString *)name{
    int64_t data;
    mpv_get_property(mpv, name.UTF8String, MPV_FORMAT_INT64, &data);
    NSLog(@"getFlag:%lld", data);
    return data > 0;
}


#pragma mark - Layer Private Method

-(void)fileLoad{
    NSLog(@"fileLoad:%@",@"........");
    _switchVideo = YES;
    
    _info.isPause = NO;
    
    double w = [self mpvGetDouble:@"width"];
    double h = [self mpvGetDouble:@"height"];
    
    [[[SMCore Instance] player].info setWidth:w];
    [[[SMCore Instance] player].info setHeight:h];
    
    
    // init window
    NSSize screenSize = [NSApp mainWindow].screen.visibleFrame.size;
    [[NSApp mainWindow] setFrame:NSMakeRect((screenSize.width-w)/2, (screenSize.height-h)/2, w, h) display:YES animate:YES];
    
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
        [[[SMCore Instance] player].info setIsPause:YES];
        _switchVideo = NO;
        int data = 1;
        mpv_set_property(mpv, "pause", MPV_FORMAT_FLAG, &data);
    }
}

-(void)resume{
    if(![self mpvGetFlag:@"eof-reached"]){
        NSLog(@"eof-reached");
        NSString *d = @"0";
        [self seek:d option:SMSeekNormal];
    }
    
    [self start];
}

-(void)start{
    if (mpv) {
        _switchVideo = YES;
       [[[SMCore Instance] player].info setIsPause:NO];
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

-(void)seek:(NSString *)second option:(SMSeek)option{
    if (self->mpv){
        const char *args[] = {"seek", second.UTF8String, "exact", NULL};
        switch (option) {
            case SMSeekNormal:
                args[2] = "exact";
                break;
            case SMSeekRelative:
                args[2] = "relative+exact";
                break;
            case SMSeekAbsolute:
                args[2] = "absolute+exact";
                break;
            default:
                break;
        }
        mpv_command(self->mpv, args);
    }
}

-(void)frameStep:(BOOL)backwards{
    NSString *cmd = @"frame-back-step";
    
    if (backwards){
        cmd = @"frame-step";
    }
    
    const char *args[] = {cmd.UTF8String, NULL};
    if (self->mpv){
        mpv_command(self->mpv, args);
    }
}

-(void)setSpeed:(double)speed{
    if (mpv){
        double data = speed;
        mpv_set_property(mpv, "speed", MPV_FORMAT_DOUBLE, &data);
    }
}

-(void)screenshot{
    BOOL tookScreenshot = NO;
    

    if (mpv){
        const char *args[] = {"screenshot", "video", NULL};
        mpv_command(mpv, args);
    }
    
    if (tookScreenshot){
        [[NSPasteboard generalPasteboard] clearContents];
//        [[NSPasteboard generalPasteboard] writeObjects:[]];
    }
}

@end
