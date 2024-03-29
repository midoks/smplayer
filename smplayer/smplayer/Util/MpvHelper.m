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
#import "SMOptionObserverInfo.h"
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
}
@property (nonatomic,strong) NSString *clientName;
@property (nonatomic,strong) NSString *mpvVersion;

@property (nonatomic) NSMutableDictionary<NSString *,SMOptionObserverInfo*> *optionObserver;
@property (nonatomic,strong) Player *player;
@property (nonatomic, weak) NSTimer *asyncPlayerTimer;


@property  dispatch_queue_t queue;

@property double videoDuration;
@property double videoPos;
@property NSString *currentPath;

@property (nonatomic,strong) NSDictionary* observeProperties;

@end


@implementation MpvHelper

-(id)init{
    self = [super init];
    if (self){
        _optionObserver = [[NSMutableDictionary alloc] init];
        _observeProperties = @{
            @"pause":[NSString stringWithFormat:@"%d", MPV_FORMAT_FLAG],
        };
    }
    return self;
}

-(id)init:(Player*)player{
    self = [self init];
    _player = player;
    return self;
}

-(void)openVideo:(NSString *)path {
    _player.info.currentURL = [NSURL fileURLWithPath:path];
    _currentPath = path;
    
    const char *cmd[] = {"loadfile", path.UTF8String, NULL};
    check_error(mpv_command(mpv, cmd));
}

-(void)setUserOption:(NSString *)key
              option:(SMUserOption)option
                name:(NSString*)name
{
    [self setUserOption:key option:option name:name sync:YES callback:NULL];
}

-(void)setUserOption:(NSString *)key
              option:(SMUserOption)option
                name:(NSString*)name
            callback:(NSString* (^)(NSString *key))callback
{
    [self setUserOption:key option:option name:name sync:YES callback:callback];
}

-(void)setUserOption:(NSString *)key
              option:(SMUserOption)option
                name:(NSString*)name
                sync:(BOOL)sync
            callback:(NSString* (^)(NSString *key))callback
{
    int32_t code = 0;
    switch(option){
        case SMInt:{
            NSInteger value = [[Preference Instance] integerForKey:key];
            int64_t i = (int64_t)value;
            code = mpv_set_option(mpv, name.UTF8String, MPV_FORMAT_INT64, &i);
            break;
        }
        case SMFloat:{
            float value = [[Preference Instance] floatForKey:key];
            code = mpv_set_option(mpv, name.UTF8String, MPV_FORMAT_DOUBLE, &value);
            break;
        }
        case SMBool:{
            BOOL value = [[Preference Instance] boolForKey:key];
            code = mpv_set_option_string(mpv, name.UTF8String, value?"yes":"no");
            break;
        }
        case SMString:{
            NSString *value = [[Preference Instance] stringForKey:key];
            code = mpv_set_option_string(mpv, name.UTF8String, value.UTF8String);
            break;
        }
        case SMColor:{
            NSString *value = [[Preference Instance] colorForKey:key];
            code = mpv_set_option_string(mpv, name.UTF8String, value.UTF8String);
            if (code < 0) {
                code = mpv_set_option_string(mpv, name.UTF8String, value.UTF8String);
            }
            break;
        }
        case SMOther:{
            if (callback){
                NSString *value = callback(key);
                code = mpv_set_option_string(mpv, name.UTF8String, value.UTF8String);
            } else {
                code = 0;
            }
            break;
        }
    }
    
    if (sync){
        [[NSUserDefaults standardUserDefaults] addObserver:self
                                                forKeyPath:key
                                                   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                                   context:nil];
        
        
        _optionObserver[key] = [[SMOptionObserverInfo alloc] init:key name:name option:option callback:callback];
        
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    SMOptionObserverInfo *info = _optionObserver[keyPath];
    switch (info.option){
        case SMInt:{
            NSInteger value = [[Preference Instance] integerForKey:keyPath];
            [self setInt:info.name value:value];
            break;
        }
        case SMFloat:{
            float value = [[Preference Instance]  floatForKey:keyPath];
            [self setDouble:info.name value:value];
            break;
        }
        case SMBool:{
            BOOL value = [[Preference Instance] boolForKey:keyPath];
            [self setFlag:info.name flag:value];
            break;
        }
        case SMString:{
            NSString *value = [[Preference Instance] stringForKey:keyPath];
            [self setString:info.name value:value];
            break;
        }
        case SMColor:{
            NSString *color = [[Preference Instance] colorForKey:keyPath];
            [self setString:info.name value:color];
            break;
        }
        case SMOther:{
            if (info.callback){
                NSString *value = info.callback(info.key);
                [self setString:info.name value:value];
            }
            break;
        }
    }
}

-(void)renderMPV{
    [self initMPV];
    [self initVideoRender];
}

-(void)optionGerenralSet{
    
    [self setUserOption:SM_PGG_ScreenShotFolder option:SMOther name:@"screenshot-directory" callback:^NSString *(NSString *key) {
        NSString *screenshotPath = [[Preference Instance] stringForKey:key];
        return screenshotPath.stringByExpandingTildeInPath;
    }];
    
    [self setUserOption:SM_PGG_ScreenShotFormat option:SMOther name:@"screenshot-format" callback:^NSString *(NSString *key) {
        NSInteger index = [[Preference Instance] integerForKey:key];
        return [[Preference Instance] screenshotFormatToString:index];
    }];
    [self setUserOption:SM_PGG_ScreenShotTemplate option:SMString name:@"screenshot-template"];
    
    [self setUserOption:SM_PGG_KeepOpenOnFileEnd option:SMOther name:@"keep-open" callback:^NSString *(NSString *key) {
        BOOL keepOpen = [[Preference Instance] boolForKey:key];
        return keepOpen ? @"yes":@"no";
    }];
    
}

-(void)optionSubtitleSet{
    [self setUserOption:SM_PGS_SubTextFont option:SMString name:@"sub-font"];
    [self setUserOption:SM_PGS_SubTextSize option:SMInt name:@"sub-font-size"];
    
    [self setUserOption:SM_PGS_SubTextColor option:SMColor name:@"sub-color"];
    [self setUserOption:SM_PGS_SubBgColor option:SMColor name:@"sub-back-color"];
    
    [self setUserOption:SM_PGS_SubBold option:SMBool name:@"sub-bold"];
    [self setUserOption:SM_PGS_SubItalic option:SMBool name:@"sub-italic"];
    
    [self setUserOption:SM_PGS_SubBorderSize option:SMInt name:@"sub-border-size"];
    [self setUserOption:SM_PGS_SubBorderColor option:SMColor name:@"sub-border-color"];
    
    [self setUserOption:SM_PGS_SubAlignX option:SMOther name:@"sub-align-x" callback:^NSString *(NSString *key) {
        NSInteger index = [[Preference Instance] integerForKey:key];
        return [[Preference Instance] subAlignXToString:index];
    }];
    
    [self setUserOption:SM_PGS_SubAlignY option:SMOther name:@"sub-align-y" callback:^NSString *(NSString *key) {
        NSInteger index = [[Preference Instance] integerForKey:key];
        return [[Preference Instance] subAlignYToString:index];
    }];
    
    [self setUserOption:SM_PGS_SubMarginX option:SMInt name:@"sub-margin-x"];
    [self setUserOption:SM_PGS_SubMarginY option:SMInt name:@"sub-margin-y"];
    
    [self setUserOption:SM_PGS_SubPos option:SMInt name:@"sub-pos"];
    [self setUserOption:SM_PGS_DisplayInLetterBox option:SMBool name:@"sub-use-margins"];
    [self setUserOption:SM_PGS_DisplayInLetterBox option:SMBool name:@"sub-ass-force-margins"];
    [self setUserOption:SM_PGS_SubScaleWithWindow option:SMBool name:@"sub-scale-by-window"];
}

-(void)optionCodecSet{
    [self setUserOption:SM_PGC_AudioThreads option:SMInt name:@"ad-lavc-threads"];
    [self setUserOption:SM_PGC_VideoThreads option:SMInt name:@"vd-lavc-threads"];
    
    [self setUserOption:SM_PGC_HardwareDecoder option:SMOther name:@"hwdec" callback:^NSString *(NSString *key) {
        NSInteger index = [[Preference Instance] integerForKey:key];
        return [[Preference Instance] hardwareDecoderOptionToString:index];
    }];
    
    NSMutableArray *spdif = [[NSMutableArray alloc] init];
    if ([[Preference Instance] boolForKey:SM_PGC_SpdifAC3]){
        [spdif addObject:@"ac3"];
    }
    if ([[Preference Instance] boolForKey:SM_PGC_SpdifDTS]){
        [spdif addObject:@"dts"];
    }
    if ([[Preference Instance] boolForKey:SM_PGC_SpdifDTSHD]){
        [spdif addObject:@"dts-hd"];
    }
    [self setString:@"audio-spdif" value:[spdif componentsJoinedByString:@","]];
    
    [self setUserOption:SM_PGC_AudioDevice option:SMString name:@"audio-device"];
}

-(void)optionNetworkSet{
    [self setUserOption:SM_PGN_EnableCache option:SMOther name:@"cache" callback:^NSString *(NSString *key) {
        return [[Preference Instance] boolForKey:key]?  @"yes" : @" no";
    }];
    
    [self setUserOption:SM_PGN_DefaultCacheSize option:SMOther name:@"demuxer-max-bytes" callback:^NSString *(NSString *key) {
        NSInteger index = [[Preference Instance] integerForKey:key];
        return  [NSString stringWithFormat:@"%ldKiB",index];
    }];
    [self setUserOption:SM_PGN_SecPrefech option:SMInt name:@"cache-secs"];
    [self setUserOption:SM_PGN_UserAgent option:SMString name:@"user-agent"];
    
    [self setUserOption:SM_PGN_TransportRTSPThrough option:SMOther name:@"rtsp-transport" callback:^NSString *(NSString *key) {
        NSInteger index =  [[Preference Instance] integerForKey:SM_PGN_TransportRTSPThrough];
        return [[Preference Instance] rtspTransportationOptionToString:index];
    }];
    
    [self setUserOption:SM_PGN_YtdlEnabled option:SMBool name:@"ytdl"];
    [self setUserOption:SM_PGN_YtdlRawOptions option:SMString name:@"ytdl-raw-options"];
}

-(void)initMPV{
    _queue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL);
    mpv = mpv_create();
    
    const char *cname = mpv_client_name(mpv);
    _clientName =  [NSString stringWithUTF8String:cname];
    
    // gerenral
    [self optionGerenralSet];
    // subtitle
    [self optionSubtitleSet];
    // codec
    [self optionCodecSet];
    // network
    [self optionNetworkSet];
    
    mpv_set_option_string(mpv,"reset-on-next-file","ab-loop-a,ab-loop-b");
    
    
    for (NSString *key in [_observeProperties allKeys] ) {
        NSString *val = [_observeProperties objectForKey:key];
        mpv_observe_property(mpv,0,key.UTF8String,[val intValue]);
    }
    
    //libmpv,gpu,opengl
    mpv_set_property_string(mpv, "vo", "libmpv");
    mpv_set_property_string(mpv, "keepaspect", "yes");
    mpv_set_property_string(mpv, "gpu-hwdec-interop", "auto");
    
    //#ifdef ENABLE_LEGACY_GPU_SUPPORT
    //    check_error( mpv_set_option_string(mpv, "hwdec", "videotoolbox"));
    //    check_error( mpv_set_option_string(mpv, "hwdec-image-format", "uyvy422"));
    //#endif
    
    mpv_request_log_messages(mpv, "warn");
    check_error(mpv_initialize(mpv));
    
    _mpvVersion = [self getString:@"mpv-version"];
    
    mpv_set_wakeup_callback(mpv, wakeup, (__bridge void *) self);
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
        case MPV_EVENT_LOG_MESSAGE: {
            struct mpv_event_log_message *msg = (struct mpv_event_log_message *)event->data;
            printf("[%s] %s: %s", msg->prefix, msg->level, msg->text);
            break;
        }
        case MPV_EVENT_PROPERTY_CHANGE:{
            mpv_event_property *property = event->data;
            [self handlePropertyChange:property];
            break;
        }
        case MPV_EVENT_SHUTDOWN: {
            if (mpv){
                mpv_detach_destroy(mpv);
                mpv = NULL;
            }
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
                [self fileLoaded];
            });
            break;
        }
            
        case MPV_EVENT_PLAYBACK_RESTART:{
            [_player syncUI:SM_SO_TIME];
            break;
        }
        case MPV_EVENT_VIDEO_RECONFIG: {
            NSLog(@"MPV_EVENT_VIDEO_RECONFIG");
            break;
        }
        case MPV_EVENT_IDLE:{
            _player.info.isIdle = YES;
            break;
        }
        default:{
            //            NSLog(@"event-default: %s\n", mpv_event_name(event->event_id));
            break;
        }
    }
}

static void render_context_callback(void *ctx) {
    MpvHelper *this = (__bridge MpvHelper *)ctx;
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [this->_player.videoView.smLayer display];
    //    });
    dispatch_async(this.queue, ^{
        [this->_player.videoView.smLayer display];
    });
}

#pragma mark - mpv_event_property
-(void)handlePropertyChange:(mpv_event_property*)property {
    //    NSLog(@"property->name:%s", property->name);
    
    if (strncmp(property->name,"pause",strlen("pause"))==0){
        bool *b = property->data;
        if (*b){
            [_player.info setIsPause:YES];
        } else {
            [_player.info setIsPause:NO];
        }
        [_player syncUI:SM_SO_PlayButton];
    }
}

#pragma mark - MPV Node Methods
-(mpv_node)nodeCreate:(NSObject *)obj{
    mpv_node node;
    
    if (obj == nil){
        node.format = MPV_FORMAT_NONE;
        return node;
    }
    
    NSString *stype = [[obj class] description];
    
    //    NSLog(@"stype:%@", stype);
    if ([stype isEqualToString:@"__NSCFNumber"]){
        node.format = MPV_FORMAT_INT64;
        node.u.int64 = [[NSString stringWithFormat:@"%@", obj] integerValue];
    } else if ([stype isEqualToString:@"__NSAD"]) {
        node.format = MPV_FORMAT_DOUBLE;
        node.u.double_ = [[NSString stringWithFormat:@"%@", obj] doubleValue];
    } else if( [stype isEqualToString:@"__NSCFBoolean"]) {
        node.format = MPV_FORMAT_FLAG;
        node.u.flag = (obj) ? 1 : 0;
    }else if ([stype isEqualToString:@"__NSCFConstantString"]){
        node.format = MPV_FORMAT_STRING;
        node.u.string = (char *)[NSString stringWithFormat:@"%@", obj].UTF8String;
    } else if ([stype isEqualToString:@"__NSArrayI"]){
        node.format = MPV_FORMAT_NODE_ARRAY;
        NSArray *data = (NSArray *)obj;
        NSUInteger data_count = [data count];
        
        mpv_node *node_ptr = alloca(sizeof(mpv_node)*data_count);
        mpv_node *node_iptr = node_ptr;
        
        for (int i=0; i<data_count; i++) {
            mpv_node ww_node = [self nodeCreate:[data objectAtIndex:i]];
            node_iptr = &ww_node;
            //            break;
            node_iptr++;
        }
        
        mpv_node_list nodelist;
        nodelist.num = (int)data_count;
        nodelist.values = node_ptr;
        
        mpv_node_list *nodelist_ptr = alloca(sizeof(mpv_node_list));
        nodelist_ptr = &nodelist;
        
        node.u.list = nodelist_ptr;;
        
    } else if ([stype isEqualToString:@"__NSSingleEntryDictionaryI"]){
        node.format = MPV_FORMAT_NODE_MAP;
        
        NSDictionary *obj_dic = (NSDictionary *)obj;
        NSUInteger obj_dic_num = [obj_dic count];
        
        mpv_node *value_ptr = alloca(sizeof(mpv_node)*obj_dic_num);
        char **key_ptr = alloca(sizeof(char)*obj_dic_num);
        
        mpv_node *value_iptr = value_ptr;
        char **key_iptr = key_ptr;
        
        
        for (NSObject *s in obj_dic) {
            mpv_node dic_node = [self nodeCreate:[obj_dic objectForKey:s]];
            value_iptr  = &dic_node;
            key_iptr =  (char **)[NSString stringWithFormat:@"%@", s].UTF8String;
            
            value_iptr++;
            key_iptr++;
        }
        
        mpv_node_list list;
        list.num = (int)obj_dic_num;
        list.keys = key_ptr;
        list.values = value_ptr;
        
        node.u.list = &list;
    } else {
        node.format = MPV_FORMAT_NONE;
    }
    
    return node;
}

-(id)nodeParse:(mpv_node)node {
    int node_num = 0;
    mpv_node *c_node_ptr;
    mpv_node_list *map = NULL;
    NSString *v = NULL;
    NSString *k = NULL;
    NSMutableDictionary * dict= [[NSMutableDictionary alloc] init];
    NSMutableArray *nList = [[NSMutableArray alloc] init];
    
    switch (node.format) {
        case MPV_FORMAT_FLAG:
            v = [NSString stringWithFormat:@"%d",node.u.flag];
            return v;
        case MPV_FORMAT_STRING:
            v = [NSString stringWithCString:node.u.string encoding:NSUTF8StringEncoding];
            return v;
        case MPV_FORMAT_INT64:
            v = [NSString stringWithFormat:@"%lld",node.u.int64];
            return v;
        case MPV_FORMAT_DOUBLE:
            v = [NSString stringWithFormat:@"%f",node.u.double_];
            return v;
        case MPV_FORMAT_NODE_ARRAY:
            node_num = node.u.list->num;
            c_node_ptr = node.u.list->values;
            for (int i=0; i<node_num;i++){
                dict = [self nodeParse:*c_node_ptr];
                c_node_ptr++;
                [nList addObject:dict];
            }
            return nList;
        case MPV_FORMAT_NODE_MAP:
            map = node.u.list;
            if (map->num == 0){
                return dict;
            }
            if (map->keys == NULL){
                return dict;
            }
            c_node_ptr = map->values;
            char **node_key = map->keys;
            
            for (int i=0; i<map->num;i++){
                v = [self nodeParse:*c_node_ptr];
                k = [NSString stringWithCString:*node_key encoding:NSUTF8StringEncoding];
                dict[k] = v;
                c_node_ptr++;
                node_key++;
            }
            return dict;
        case MPV_FORMAT_BYTE_ARRAY:
            break;
        case MPV_FORMAT_NONE:
            break;
        default:
            break;
    }
    return @"";
}


#pragma mark - MPV Private Methods

-(void)command{
    
}

-(id)getNode:(NSString *)name {
    mpv_node node ;
    mpv_get_property(mpv, name.UTF8String, MPV_FORMAT_NODE, &node);
    NSMutableArray *list = [self nodeParse:node];
    mpv_free_node_contents(&node);
    return list;
}

-(void)getScreenshot:(NSString *) args{
    mpv_node node_args = [self nodeCreate:@[@"screenshot-raw", args]];
    mpv_node result;
    
    mpv_command_node(mpv, &node_args, &result);
    //    id data = [self nodeParse:result];
    mpv_free_node_contents(&result);
    
    //    NSLog(@"ssss:%@", args);
    //    NSLog(@"ss:%@", data);
}

#pragma mark - MPV Public Methods
-(int)getInt:(NSString *)name {
    int64_t data;
    mpv_get_property(mpv, name.UTF8String, MPV_FORMAT_INT64, &data);
    return (int)data;
}

-(void)setInt:(NSString *)name value:(NSInteger)value{
    int64_t data;
    data = value;
    mpv_set_property(mpv, name.UTF8String, MPV_FORMAT_INT64, &data);
}

-(double)getDouble:(NSString *)name {
    int64_t data;
    mpv_get_property(mpv, name.UTF8String, MPV_FORMAT_INT64, &data);
    return (double)data;
}

-(void)setDouble:(NSString *)name value:(double)value{
    //    double data;
    //    data = value;
    mpv_set_property(mpv, name.UTF8String, MPV_FORMAT_DOUBLE, &value);
}

-(NSString *)getString:(NSString *)name{
    char *value = mpv_get_property_string(mpv, name.UTF8String);
    return [NSString stringWithUTF8String:value];
}

-(void)setString:(NSString *)name value:(NSString *)value{
    mpv_set_property_string(mpv, name.UTF8String, value.UTF8String);
}

-(BOOL)getFlag:(NSString *)name{
    int64_t data;
    mpv_get_property(mpv, name.UTF8String, MPV_FORMAT_FLAG, &data);
    return (int)data > 0;
}

-(void)setFlag:(NSString *)name flag:(BOOL)flag{
    int data;
    data = flag ? 1 : 0;
    mpv_set_property(mpv, name.UTF8String, MPV_FORMAT_FLAG, &data);
}

-(BOOL)shouldRenderUpdateFrame{
    if (!_context){return NO;}
    uint64_t flags = mpv_render_context_update(_context);
    return (flags & (int64_t)MPV_RENDER_UPDATE_FRAME)>0;
}

#pragma mark - Event Methods

-(void)fileStart{
//    NSLog(@"fileStart");
    [_player.info setIsValid:NO];
}

-(void)fileLoaded{
    
    double w = [self getDouble:@"width"];
    double h = [self getDouble:@"height"];
    
    [_player.info setWidth:w];
    [_player.info setHeight:h];
    [_player.info setIsPause:NO];
    
    // init window
    NSSize screenSize = [NSApp mainWindow].screen.visibleFrame.size;
    [[NSApp mainWindow] setFrame:NSMakeRect((screenSize.width-w)/2, (screenSize.height-h)/2, w, h) display:YES animate:YES];
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(videoDurationAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.asyncPlayerTimer  = timer;
    
    self->_videoDuration = [self getDouble:@"duration"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_player videoStart:[[SMVideoTime alloc] initTime:self->_videoDuration]];
    });
    
    NSURL *urlFile = [NSURL fileURLWithPath:self->_currentPath isDirectory:NO];
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:urlFile];
    [[NSNotificationCenter defaultCenter] postNotificationName:SM_NOTIF_FILELOADED object:nil userInfo:nil];
    //    [[SMLastHistory Instance] add:urlFile duration:2.0];
}


-(void)videoDurationAction{
    double pos = [self getDouble:@"time-pos"];
    if (pos>_videoDuration){
        pos = _videoDuration;
    }
    _videoPos = pos;
    // [[SMLastHistory Instance] add:[NSURL fileURLWithPath:self->_currentPath isDirectory:NO] duration:_videoPos];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_player videoPos:[[SMVideoTime alloc] initTime:pos]];
    });
    
}

-(void)closeVideo{
    [self stop];
    [[NSUserDefaults standardUserDefaults] setObject:self->_currentPath forKey:SM_FILE_PATH];
    [[NSUserDefaults standardUserDefaults] setDouble:_videoPos forKey:SM_FILE_POS];
}

-(void)toggleVideo{
    if([self getFlag:@"pause"]){
        [self start];
    } else {
        [self stop];
    }
}

-(void)toggleVoice{
    BOOL mute = [self getFlag:@"mute"];
    int data = mute ? 0 : 1;
    mpv_set_property(mpv, "mute", MPV_FORMAT_FLAG, &data);
}

-(void)setVoice:(double)value{
    
    [_player.info setVolume:value];
    double data = value;
    mpv_set_property_async(mpv, 0, "volume", MPV_FORMAT_DOUBLE, &data);
    
}

-(void)stop{
    [_player.info setIsPause:YES];
    int data = 1;
    mpv_set_property(mpv, "pause", MPV_FORMAT_FLAG, &data);
    
}

-(void)start{
    if (mpv) {
        [_player.info setIsPause:NO];
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

-(void)seek:(NSString *)second option:(SMSeek)option{
    
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
    double data = speed;
    mpv_set_property(mpv, "speed", MPV_FORMAT_DOUBLE, &data);
    
}

-(void)setAudioDelay:(double)delay{
    
    double data = delay;
    mpv_set_property(mpv, "audio-delay", MPV_FORMAT_DOUBLE, &data);
    
}

-(void)screenshot{
    NSString *option =  [[Preference Instance] boolForKey:SM_PGG_ScreenShotIncludeSubtitle]? @"subtitles" : @"video";
    BOOL tookScreenshot = NO;
    int code = 0;
    if ([[Preference Instance] boolForKey:SM_PGG_ScreenshotSaveToFile]){
        const char *args[] = {"screenshot", option.UTF8String, NULL};
        code = mpv_command(mpv, args);
        tookScreenshot = YES;
    }
    if (code < 0){return;}
    
    if (tookScreenshot){
        if ([[Preference Instance] boolForKey:SM_PGG_ScreenshotCopyToClipboard]){
            //            [self getScreenshot:option];
            //   [[NSPasteboard generalPasteboard] clearContents];
            //   [[NSPasteboard generalPasteboard] writeObjects:[]];
        }
    }
    
    if (tookScreenshot){
        if ([[Preference Instance] boolForKey:SM_PGG_ScreenshotOkToOpen]){
            NSString *file = [[Preference Instance] stringForKey:SM_PGG_ScreenShotFolder];
            [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:file]];
        }
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
