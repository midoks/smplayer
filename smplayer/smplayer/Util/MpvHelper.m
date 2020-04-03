//
//  MpvHelper.m
//  smplayer
//
//  Created by midoks on 2020/3/21.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMCore.h"
#import "SMCommon.h"
#import "SMLastHistory.h"

#import "Player.h"
#import "MpvHelper.h"


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

@interface MpvHelper(){
    mpv_handle *mpv;
    mpv_render_context *sm_render_context;
}

@property (nonatomic,strong) Player *player;
@property (nonatomic, weak) NSTimer *asyncPlayerTimer;
@property  dispatch_queue_t queue;
@property BOOL switchVoice;
@property BOOL switchVideo;
@property double videoDuration;
@property double videoPos;
@property NSString *currentPath;

@end


@implementation MpvHelper

-(id)init{
    self = [super init];
    if (self){
    }
    return self;
}

-(id)init:(Player*)player{
    self = [self init];
    _player = player;
    return self;
}

-(void)openVideo:(NSString *)path {
    _currentPath = path;
    mpv_set_wakeup_callback(mpv, wakeup, (__bridge void *) self);
    const char *cmd[] = {"loadfile", path.UTF8String, NULL};
    check_error(mpv_command(mpv, cmd));
}

-(void)renderMPV{
    [self initMPV];
    [self initVideoRender];
}

-(void)initMPV{
    _queue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL);
    mpv = mpv_create();
    if (!mpv) {
        NSLog(@"%@", @"failed creating context");
        exit(-1);
    }
    
    mpv_set_option_string(mpv,"reset-on-next-file","ab-loop-a,ab-loop-b");
    
    
    //libmpv,gpu,opengl
    mpv_set_property_string(mpv, "vo", "libmpv");
    mpv_set_property_string(mpv, "keepaspect", "yes");
    mpv_set_property_string(mpv, "gpu-hwdec-interop", "auto");
    
#ifdef ENABLE_LEGACY_GPU_SUPPORT
    check_error( mpv_set_option_string(mpv, "hwdec", "videotoolbox"));
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
    
    if (mpv_render_context_create(&_context, mpv, params) < 0) {
        puts("failed to initialize mpv GL context");
        exit(1);
    }
    
    mpv_render_context_set_update_callback(_context, render_context_callback, (__bridge void *)self);
}

static void wakeup(void *context) {
    MpvHelper *class = (__bridge MpvHelper *) context;
    [class readEvents];
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

-(void)handleEvent:(mpv_event *)event
{
    switch (event->event_id) {
        case MPV_EVENT_SHUTDOWN: {
            if (mpv){
                mpv_detach_destroy(mpv);
                mpv = NULL;
            }
            NSLog(@"event-MPV_EVENT_SHUTDOWN: shutdown");
            break;
        }
        case MPV_EVENT_START_FILE:{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self fileStart];
            });
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
            NSLog(@"%@", event);
            //
            //            let dataOpaquePtr = OpaquePointer(event.pointee.data)
            //            if let property = UnsafePointer<mpv_event_property>(dataOpaquePtr)?.pointee {
            //              let propertyName = String(cString: property.name)
            //              handlePropertyChange(propertyName, property)
            //            }
            
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
        case MPV_EVENT_IDLE:{
            [[SMCore Instance] player].info.isIdle = YES;
            break;
        }
        default:{
            NSLog(@"event-default: %s\n", mpv_event_name(event->event_id));
            break;
        }
    }
}

static void render_context_callback(void *ctx) {
    MpvHelper *this = (__bridge MpvHelper *)ctx;
    dispatch_async(dispatch_get_main_queue(), ^{
        [this->_player.videoView.smLayer display];
    });
}

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

-(BOOL)shouldRenderUpdateFrame{
    if (!_context){return NO;}
    uint64_t flags = mpv_render_context_update(_context);
    return (flags & (int64_t)MPV_RENDER_UPDATE_FRAME)>0;
}

#pragma mark - Event Methods

-(void)fileStart{
    NSLog(@"fileStart");
    [_player.info setIsValid:NO];
}

-(void)fileLoad{
    
    [_player.info setIsPause:NO];
    
    double w = [self mpvGetDouble:@"width"];
    double h = [self mpvGetDouble:@"height"];
    
    [_player.info setWidth:w];
    [_player.info setHeight:h];
    
    // init window
    NSSize screenSize = [NSApp mainWindow].screen.visibleFrame.size;
    [[NSApp mainWindow] setFrame:NSMakeRect((screenSize.width-w)/2, (screenSize.height-h)/2, w, h) display:YES animate:YES];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(videoDurationAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.asyncPlayerTimer  = timer;
    
    
    self->_videoDuration = [self mpvGetDouble:@"duration"];
    [_player videoStart:[[SMVideoTime alloc] initTime:self->_videoDuration]];
    
    NSURL *urlFile = [NSURL fileURLWithPath:self->_currentPath isDirectory:NO];
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:urlFile];
    [[NSNotificationCenter defaultCenter] postNotificationName:SM_NOTIF_FILELOADED object:nil userInfo:nil];
    //    [[SMLastHistory Instance] add:urlFile duration:2.0];
}


-(void)videoDurationAction{
    double pos = [self mpvGetDouble:@"time-pos"];
    if (pos>_videoDuration){
        pos = _videoDuration;
    }
    _videoPos = pos;
    // [[SMLastHistory Instance] add:[NSURL fileURLWithPath:self->_currentPath isDirectory:NO] duration:_videoPos];
    [_player videoPos:[[SMVideoTime alloc] initTime:pos]];
}

-(void)closeVideo{
    [self stop];
    [[NSUserDefaults standardUserDefaults] setObject:self->_currentPath forKey:SM_FILE_PATH];
    [[NSUserDefaults standardUserDefaults] setDouble:_videoPos forKey:SM_FILE_POS];
}

-(void)toggleVideo{
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
        [_player.info setVolume:value];
        double data = value;
        mpv_set_property_async(mpv, 0, "volume", MPV_FORMAT_DOUBLE, &data);
    }
}

-(void)stop{
    if (mpv) {
        [_player.info setIsPause:YES];
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
        [_player.info setIsPause:NO];
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

-(void)windowScale:(double)scale{
    if (self->mpv) {
        double data = scale;
        mpv_set_property(mpv, "window-scale", MPV_FORMAT_DOUBLE, &data);
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

-(void)setAudioDelay:(double)delay{
    if (mpv){
        double data = delay;
        mpv_set_property(mpv, "audio-delay", MPV_FORMAT_DOUBLE, &data);
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

-(void)loadSubtitle:(NSURL *)url{
    const char *args[] = {"sub-add", [url path].UTF8String, NULL};
    int code = mpv_command(mpv, args);
    if (code < 0 ){
        NSLog(@"load:%@",@"fail");
    }
}


@end
