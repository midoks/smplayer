//
//  VideoView.m
//  smplayer
//
//  Created by midoks on 2020/2/12.
//  Copyright © 2020 midoks. All rights reserved.
//

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavfilter/avfilter.h>
#include <libavfilter/buffersrc.h>
#include <libavfilter/buffersink.h>
#include <libavutil/opt.h>
};

#import <CoreImage/CoreImage.h>
#import <AudioToolbox/AudioToolbox.h>

#import "PlayESView.h"
#import "VideoView.h"
#import <MetalKit/MetalKit.h>

@interface VideoView()
@property (nonatomic, assign) AUGraph graph;
@property (nonatomic, assign) AUNode node;
@property (nonatomic, assign) AudioUnit unit;
@end

@implementation VideoView
{
    id<MTLComputePipelineState> _pipelineState;
    id<MTLCommandQueue> _commandQueue;
    CVMetalTextureCacheRef _textCache;
    
    
    AVFormatContext * pFormatCtx;
    
    // 视频
    AVCodecContext * pCodecCtx;
    AVCodec * pCodec;
    
    // 声音
    AVCodecContext * pAudioCodecCtx;
    AVCodec * pAudioCodec;
    
    NSInteger videoIndex; /// 视频索引
    NSInteger audioIndex; /// 声音索引
    
    AVFilterContext * buffer_ctx;
    AVFilterContext * bufferSink_ctx;
    
    // 声音
    AVFilterContext * buffersrc_ctx;
    AVFilterContext * buffersink_ctx;
    AVFilterGraph * filter_graph;
    enum AVSampleFormat sampleFormat;
    
    CVDisplayLinkRef displayLink;
    
    double fps;
    
    NSTimer * timer;
    
    NSInteger videoDuration;
    
    CVPixelBufferPoolRef pixelBufferPool;
    
    CIContext * context;
    
    NSRect frame;
    NSImageView *imageView;
    
    FILE * file1;
    FILE * file2;
}

- (id)initWithFrame:(NSRect)frame{
    self.frame = frame;
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = true;
        self.layer.backgroundColor = [NSColor brownColor].CGColor;
        self->imageView = [[NSImageView alloc] initWithFrame:frame];
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
        [self initMTL];
        
        NSString * videoPath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"mp4"];
        [self initVideo:videoPath];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self startVideo];
        });
    }
    return self;
}

-(void)startVideo{
    if (file1 == NULL) {
        file1 = fopen("./text.pcm", "wb+");
    }
    
    if (file2 == NULL) {
        file2 = fopen("./text2.pcm", "wb+");
    }
    
    sampleFormat = AV_SAMPLE_FMT_S16;
    if (pAudioCodecCtx->sample_fmt != AV_SAMPLE_FMT_S16) {
        [self createFilters];
    }
    AudioStreamBasicDescription streamDescription;
    bzero(&streamDescription, sizeof(streamDescription));
    streamDescription.mFormatID = kAudioFormatLinearPCM;
    streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    streamDescription.mSampleRate = 44100.0;
    streamDescription.mChannelsPerFrame = pAudioCodecCtx->channels;
    streamDescription.mFramesPerPacket = 1;
    streamDescription.mBitsPerChannel = 16;
    streamDescription.mBytesPerFrame = (streamDescription.mBitsPerChannel / 8) * streamDescription.mChannelsPerFrame;
    streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame * streamDescription.mFramesPerPacket;
    
    OSStatus status = [self setupAudioUnitWithStreamDescription:streamDescription];
    if (status != noErr) {
        NSLog(@"setup Audio unit error");
        return;
    }
    status = AUGraphStart(_graph);
    if (status != noErr) {
        NSLog(@"Start graph error");
    }
}

-(void)initVideo:(NSString *)videoPath{
    // Do view setup here.
    videoIndex = NSNotFound;
    //    context = [CIContext context];
    context = [CIContext contextWithOptions:nil];
    [self initDecoder:videoPath];  //初始化解码器
    [self initFilters];  //初始化过滤器
    

    //    self.frame = NSRectFromCGRect(CGRectMake(0, 0, pCodecCtx->width, pCodecCtx->height));
    
    NSLog(@"获取-widht:%d, height:%d", pCodecCtx->width, pCodecCtx->height);
    
    timer = [NSTimer timerWithTimeInterval:0.9/fps repeats:YES block:^(NSTimer * _Nonnull timer) { //根据视频的fps解码渲染视频
        [self decodeVideo];  //解码视频并渲染
        [self setNeedsLayout:YES];  //刷新界面防止画面撕裂
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    //在改变尺寸时保证计时器能调用
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSEventTrackingRunLoopMode];
}

- (void)initDecoder:(NSString *)videoPath {
    //av_register_all(); FFmpeg 4.0废弃
    
    pFormatCtx = avformat_alloc_context();
    
    if ((avformat_open_input(&pFormatCtx, videoPath.UTF8String, NULL, NULL)) != 0) {
        NSLog(@"Could not open input stream");
        return;
    }
    
    if ((avformat_find_stream_info(pFormatCtx, NULL)) < 0) {
        NSLog(@"Could not find stream information");
        return;
    }
    
    audioIndex = av_find_best_stream(pFormatCtx, AVMEDIA_TYPE_AUDIO, -1, -1, NULL, 0);
    if (audioIndex == -1) {
        NSLog(@"No audio stream");
        return;
    }
    
    videoIndex = av_find_best_stream(pFormatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, NULL, 0);
    if (videoIndex == -1) {
        NSLog(@"No video stream");
        return;
    }
    
    for (NSInteger i = 0; i < pFormatCtx->nb_streams; i++) {
        if (pFormatCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            //            videoIndex = i;  //视频流的索引
            videoDuration = pFormatCtx->streams[i]->duration * av_q2d(pFormatCtx->streams[i]->time_base); //计算视频时长
            //            _totalTimeLabel.stringValue = [NSString stringWithFormat:@"%.2ld:%.2ld", videoDuration/60, videoDuration%60];
            if (pFormatCtx->streams[i]->avg_frame_rate.den && pFormatCtx->streams[i]->avg_frame_rate.num) {
                fps = av_q2d(pFormatCtx->streams[i]->avg_frame_rate);  //计算视频fps
            } else {
                fps = 30;
            }
            
            NSLog(@"视频索引:%ld",videoIndex);
        } else if (pFormatCtx->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_AUDIO) {
            NSLog(@"音频索引:%ld", i);
            //            audioIndex = i;
        }
    }
    
    if (videoIndex == NSNotFound) {
        NSLog(@"Did not find a video stream");
        return;
    }
    
    // FFmpeg 3.1 以上AVStream::codec被替换为AVStream::codecpar
    // 视频解码器
    pCodec = avcodec_find_decoder(pFormatCtx->streams[videoIndex]->codecpar->codec_id);
    pCodecCtx = avcodec_alloc_context3(pCodec);
    avcodec_parameters_to_context(pCodecCtx, pFormatCtx->streams[videoIndex]->codecpar);
    
    if (pCodec == NULL) {
        NSLog(@"Could not open codec");
        return;
    }
    
    if (avcodec_open2(pCodecCtx, pCodec, NULL) < 0) {
        NSLog(@"Could not open codec");
        return;
    }
    
    //音频解码器
    pAudioCodec = avcodec_find_decoder(pFormatCtx->streams[audioIndex]->codecpar->codec_id);
    if (pAudioCodec == NULL) {
        NSLog(@"Unsupported codec");
        return;
    }
    pAudioCodecCtx = avcodec_alloc_context3(pAudioCodec);
    avcodec_parameters_to_context(pAudioCodecCtx, pFormatCtx->streams[audioIndex]->codecpar);
    
    if (avcodec_open2(pAudioCodecCtx, pAudioCodec, NULL) < 0) {
        NSLog(@"Fail to open audio codec");
    }
    
    // 格式打印
    // av_dump_format(pFormatCtx, 0, videoPath.UTF8String, 0);
}

- (void)initFilters {
    
    //    avfilter_register_all();  //FFmpeg 4.0废弃
    
    char args[512];
    
    AVFilterInOut * inputs = avfilter_inout_alloc();
    AVFilterInOut * outputs = avfilter_inout_alloc();
    AVFilterGraph * filterGraph = avfilter_graph_alloc();
    
    const AVFilter * buffer = avfilter_get_by_name("buffer");
    const AVFilter * bufferSink = avfilter_get_by_name("buffersink");
    if (!buffer || !bufferSink) {
        NSLog(@"filter not found");
        return;
    }
    AVRational time_base = pFormatCtx->streams[videoIndex]->time_base;
    //视频的描述字符串，这些属性都是必须的否则会创建失败
    snprintf(args, sizeof(args), "video_size=%dx%d:pix_fmt=%d:time_base=%d/%d:pixel_aspect=%d/%d", pCodecCtx->width,pCodecCtx->height,pCodecCtx->pix_fmt,
             time_base.num, time_base.den,pCodecCtx->sample_aspect_ratio.num,pCodecCtx->sample_aspect_ratio.den);
    NSInteger ret = avfilter_graph_create_filter(&buffer_ctx, buffer, "in", args, NULL, filterGraph);
    if (ret < 0) {
        NSLog(@"can not create buffer source");
        return;
    }
    ret = avfilter_graph_create_filter(&bufferSink_ctx, bufferSink, "out", NULL, NULL, filterGraph);
    if (ret < 0) {
        NSLog(@"can not create buffer sink");
        return;
    }
    enum AVPixelFormat format[] = {AV_PIX_FMT_RGB24};  //想要转换的格式
    ret = av_opt_set_bin(bufferSink_ctx, "pix_fmts", (uint8_t *)&format, sizeof(AV_PIX_FMT_RGB24), AV_OPT_SEARCH_CHILDREN);
    if (ret < 0) {
        NSLog(@"set bin error");
        return;
    }
    
    outputs->name = av_strdup("in");
    outputs->filter_ctx = buffer_ctx;
    outputs->pad_idx = 0;
    outputs->next = NULL;
    
    inputs->name = av_strdup("out");
    inputs->filter_ctx = bufferSink_ctx;
    inputs->pad_idx = 0;
    inputs->next = NULL;
    
    ret = avfilter_graph_parse_ptr(filterGraph, "null", &inputs, &outputs, NULL);  //只转换格式filter名称输入null
    if (ret < 0) {
        NSLog(@"parse error");
        return;
    }
    
    ret = avfilter_graph_config(filterGraph, NULL);
    if (ret < 0) {
        NSLog(@"config error");
        return;
    }
    
    avfilter_inout_free(&inputs);
    avfilter_inout_free(&outputs);
}

- (int)createFilters {
    char args[512];
    int ret = 0;
    const AVFilter * buffersrc = NULL;
    const AVFilter * buffersink = NULL;
    buffersrc_ctx = NULL;
    buffersink_ctx = NULL;
    AVFilterInOut * outputs = avfilter_inout_alloc();
    AVFilterInOut * inputs = avfilter_inout_alloc();
    filter_graph = avfilter_graph_alloc();
    if (!outputs || !inputs || !filter_graph) {
        ret = AVERROR(ENOMEM);
        goto end;
    }
    buffersrc = avfilter_get_by_name("abuffer");
    buffersink = avfilter_get_by_name("abuffersink");
    if (!buffersrc || !buffersink) {
        NSLog(@"Filtering source or sink element not found");
        ret = AVERROR_UNKNOWN;
        goto end;
    }
    if (!pAudioCodecCtx->channel_layout) {
        pAudioCodecCtx->channel_layout = av_get_default_channel_layout(pAudioCodecCtx->channels);
    }
    snprintf(args, sizeof(args), "time_base=%d/%d:sample_rate=%d:sample_fmt=%s:channel_layout=0x%" PRIx64, pAudioCodecCtx->time_base.num, pAudioCodecCtx->time_base.den, pAudioCodecCtx->sample_rate, av_get_sample_fmt_name(pAudioCodecCtx->sample_fmt), pAudioCodecCtx->channel_layout);
    ret = avfilter_graph_create_filter(&buffersrc_ctx, buffersrc, "in", args, NULL, filter_graph);
    if (ret < 0) {
        NSLog(@"Can not create audio buffer source");
        goto end;
    }
    ret = avfilter_graph_create_filter(&buffersink_ctx, buffersink, "out", NULL, NULL, filter_graph);
    if (ret < 0) {
        NSLog(@"Can not create audio buffer sink");
        goto end;
    }
    ret = av_opt_set_bin(buffersink_ctx, "sample_fmts", (uint8_t *)&sampleFormat, sizeof(sampleFormat), AV_OPT_SEARCH_CHILDREN);
    if (ret < 0) {
        NSLog(@"Can not set output sample format");
        goto end;
    }
    ret = av_opt_set_bin(buffersink_ctx, "channel_layouts", (uint8_t *)&pAudioCodecCtx->channel_layout, sizeof(pAudioCodecCtx->channel_layout), AV_OPT_SEARCH_CHILDREN);
    if (ret < 0) {
        NSLog(@"Can not set output channel layout");
        goto end;
    }
    ret = av_opt_set_bin(buffersink_ctx, "sample_rates", (uint8_t *)&pAudioCodecCtx->sample_rate, sizeof(pAudioCodecCtx->sample_rate), AV_OPT_SEARCH_CHILDREN);
    if (ret < 0) {
        NSLog(@"Can not set output sample rate");
        goto end;
    }
    outputs->name = av_strdup("in");
    outputs->filter_ctx = buffersrc_ctx;
    outputs->pad_idx = 0;
    outputs->next = NULL;
    
    inputs->name = av_strdup("out");
    inputs->filter_ctx = buffersink_ctx;
    inputs->pad_idx = 0;
    inputs->next = NULL;
    
    if (!outputs->name || !inputs->name) {
        ret = AVERROR(ENOMEM);
        goto end;
    }
    if ((ret = avfilter_graph_parse_ptr(filter_graph, "anull", &inputs, &outputs, NULL)) < 0) {
        goto end;
    }
    if ((ret = avfilter_graph_config(filter_graph, NULL))) {
        goto end;
    }
end:
    avfilter_inout_free(&inputs);
    avfilter_inout_free(&outputs);
    return ret;
}

- (OSStatus)setupAudioUnitWithStreamDescription:(AudioStreamBasicDescription)streamDescription {
    OSStatus status = NewAUGraph(&_graph);
    if (status != noErr) {
        NSLog(@"Can not create new graph");
        return status;
    }
    
    AudioComponentDescription description;
    bzero(&description, sizeof(description));
    description.componentType = kAudioUnitType_Output;
    description.componentSubType = kAudioUnitSubType_HALOutput;
    description.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    status = AUGraphAddNode(_graph, &description, &_node);
    if (status != noErr) {
        NSLog(@"Can not add node");
        return status;
    }
    
    status = AUGraphOpen(_graph);
    if (status != noErr) {
        NSLog(@"Can not open graph");
        return status;
    }
    
    status = AUGraphNodeInfo(_graph, _node, NULL, &_unit);
    if (status != noErr) {
        NSLog(@"Can not get node info");
        return status;
    }
    
    status = AudioUnitSetProperty(_unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamDescription, sizeof(streamDescription));
    if (status != noErr) {
        NSLog(@"Can not set stream format on unit input scope");
        return status;
    }
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = &InputRenderCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)self;
    status = AudioUnitSetProperty(_unit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callbackStruct, sizeof(callbackStruct));
    if (status != noErr) {
        NSLog(@"Fail to set render callback");
        return status;
    }
    
    status = AUGraphInitialize(_graph);
    if (status != noErr) {
        NSLog(@"Can not initialize graph");
        return status;
    }
    
    [self decodeAudioData];
    
    return status;
}

static OSStatus InputRenderCallback(void * inRefCon, AudioUnitRenderActionFlags * ioActionFlags, const AudioTimeStamp * inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList * ioData) {
    VideoView * v = (__bridge VideoView *)inRefCon;
    
    return [v renderData:ioData atTimeStamp:inTimeStamp forElement:inBusNumber numberFrames:inNumberFrames flags:ioActionFlags];
}

- (OSStatus)renderData:(AudioBufferList *)ioData
           atTimeStamp:(const AudioTimeStamp *)timeStamp
            forElement:(UInt32)element numberFrames:(UInt32)numFrames
                 flags:(AudioUnitRenderActionFlags *)flags
{
    
    for (int iBuffer = 0; iBuffer < ioData->mNumberBuffers; iBuffer++) {
        memset(ioData->mBuffers[iBuffer].mData, 0, ioData->mBuffers[iBuffer].mDataByteSize);
    }
    FILE * files[] = {file1, file2};
    for (int iBuffer = 0; iBuffer < ioData->mNumberBuffers; iBuffer++) {
        FILE * file = files[iBuffer];
        if (file != NULL) {
            size_t ret = fread(ioData->mBuffers[iBuffer].mData, ioData->mBuffers[iBuffer].mDataByteSize, 1, files[iBuffer]);
//            if (ret == 0) {
//                [self destroyAudioUnitGraph];
//            }
        }
    }
    return noErr;
}

- (void)destroyAudioUnitGraph {
    AUGraphStop(_graph);
    AUGraphUninitialize(_graph);
    AUGraphClose(_graph);
    AUGraphRemoveNode(_graph, _node);
    DisposeAUGraph(_graph);
    _unit = NULL;
    _node = 0;
    _graph = NULL;
}


- (void)decodeVideo {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{  //在全局队列中解码
        AVPacket * packet = av_packet_alloc();
        if (av_read_frame(self->pFormatCtx, packet) >= 0) {
            if (packet->stream_index == self->videoIndex) {  //解码视频流
                //FFmpeg 3.0之后avcodec_send_packet和avcodec_receive_frame成对出现用于解码，包括音频和视频的解码，avcodec_decode_video2和avcodec_decode_audio4被废弃
                NSInteger ret = avcodec_send_packet(self->pCodecCtx, packet);
                if (ret < 0) {
                    NSLog(@"send packet error");
                    av_packet_free(&packet);
                    return;
                }
                AVFrame * frame = av_frame_alloc();
                ret = avcodec_receive_frame(self->pCodecCtx, frame);
                if (ret < 0) {
                    NSLog(@"receive frame error");
                    av_frame_free(&frame);
                    return;
                }
                //frame中data存放解码出的yuv数据，data[0]中是y数据，data[1]中是u数据，data[2]中是v数据，linesize对应的数据长度
                //                float time = packet->pts * av_q2d(self->pFormatCtx->streams[self->videoIndex]->time_base);  //计算当前帧时间
                av_packet_free(&packet);
                
                CVReturn theError;
                if (!self->pixelBufferPool){  //创建pixelBuffer缓存池，从缓存池中创建pixelBuffer以便复用
                    NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
                    [attributes setObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
                    [attributes setObject:[NSNumber numberWithInt:frame->width] forKey: (NSString*)kCVPixelBufferWidthKey];
                    [attributes setObject:[NSNumber numberWithInt:frame->height] forKey: (NSString*)kCVPixelBufferHeightKey];
                    [attributes setObject:@(frame->linesize[0]) forKey:(NSString*)kCVPixelBufferBytesPerRowAlignmentKey];
                    [attributes setObject:[NSDictionary dictionary] forKey:(NSString*)kCVPixelBufferIOSurfacePropertiesKey];
                    theError = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (__bridge CFDictionaryRef) attributes, &self->pixelBufferPool);
                    if (theError != kCVReturnSuccess){
                        NSLog(@"CVPixelBufferPoolCreate Failed");
                    }
                }
                
                CVPixelBufferRef pixelBuffer = nil;
                theError = CVPixelBufferPoolCreatePixelBuffer(NULL, self->pixelBufferPool, &pixelBuffer);
                if(theError != kCVReturnSuccess){
                    NSLog(@"CVPixelBufferPoolCreatePixelBuffer Failed");
                }
                
                theError = CVPixelBufferLockBaseAddress(pixelBuffer, 0);
                if (theError != kCVReturnSuccess) {
                    NSLog(@"lock error");
                }
                /*
                 PixelBuffer中Y数据存放在Plane0中，UV数据存放在Plane1中，数据格式如下
                 frame->data[0]  .........   YYYYYYYYY
                 frame->data[1]  .........   UUUUUUUU
                 frame->data[2]  .........   VVVVVVVVV
                 PixelBuffer->Plane0 .......  YYYYYYYY
                 PixelBuffer->Plane1 .......  UVUVUVUVUV
                 所以需要把Y数据拷贝到Plane0上，把U和V数据交叉拷到Plane1上
                 */
                size_t bytePerRowY = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
                size_t bytesPerRowUV = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
                //获取Plane0的起始地址
                void* base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
                memcpy(base, frame->data[0], bytePerRowY * frame->height);
                //获取Plane1的起始地址
                base = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
                uint32_t size = frame->linesize[1] * frame->height / 2;
                //把UV数据交叉存储到dstData然后拷贝到Plane1上
                uint8_t* dstData = new uint8_t[2 * size];
                uint8_t * firstData = new uint8_t[size];
                memcpy(firstData, frame->data[1], size);
                uint8_t * secondData  = new uint8_t[size];
                memcpy(secondData, frame->data[2], size);
                for (int i = 0; i < 2 * size; i++){
                    if (i % 2 == 0){
                        dstData[i] = firstData[i/2];
                    }else {
                        dstData[i] = secondData[i/2];
                    }
                }
                memcpy(base, dstData, bytesPerRowUV * frame->height/2);
                CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                av_frame_free(&frame);
                free(dstData);
                free(firstData);
                free(secondData);
                
                //                CIImage *coreImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
                //                CGImageRef videoImage = [self->context createCGImage:coreImage
                //                                                                   fromRect:CGRectMake(0, 0, self->pCodecCtx->width, self->pCodecCtx->height)];
                //                NSImage * image = [[NSImage alloc] initWithCGImage:videoImage size:NSSizeFromCGSize(CGSizeMake(self->pCodecCtx->width, self->pCodecCtx->height))];
                //                CVPixelBufferRelease(pixelBuffer);
                //                CGImageRelease(videoImage);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    self.label.stringValue = [NSString stringWithFormat:@"%.2d:%.2d", (int)time/60, (int)time%60];
                    //                    self->imageView.image = image;
                    //                    PlayESView * esView = (PlayESView *)self;
                    
                    [self renderWithPixelBuffer:pixelBuffer];
                    //                    NSLog(@"%f",time / (float)self->videoDuration);
                });
            } else if (packet->stream_index == self->audioIndex){
                //                AVPacket * packetAudio = av_packet_alloc();
                //                NSInteger ret = avcodec_send_packet(self->pAudioCodecCtx, packetAudio);
                //
                //                while (ret >= 0) {
                //                    NSLog(@"frame:%ld", (long)ret);
                //                    AVFrame * frame = av_frame_alloc();
                //                    ret = avcodec_receive_frame(self->pAudioCodecCtx, frame);
                //                    if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
                //                        break;
                //                    } else if (ret < 0) {
                //                        NSLog(@"Error during ecoding");
                //                        break;
                //                    }
                //
                //                    if (self->filter_graph != NULL) {
                //                        int retCode = av_buffersrc_add_frame_flags(self->buffersrc_ctx, frame, 0);
                //                        if (retCode >= 0) {
                //                            AVFrame * filt_frame = av_frame_alloc();
                //                            retCode = av_buffersink_get_frame(self->buffersink_ctx, filt_frame);
                //                            frame = av_frame_clone(filt_frame);
                //                            av_frame_free(&filt_frame);
                //                        }
                //                    }
                //                    switch (self->sampleFormat) {
                //                        case AV_SAMPLE_FMT_S16: {
                //                            int data_size = av_samples_get_buffer_size(frame->linesize, frame->channels, frame->nb_samples, AV_SAMPLE_FMT_S16, 0);
                //                            fwrite(frame->data[0], 1, data_size, self->file1);
                //                        }
                //                            break;
                //                        case AV_SAMPLE_FMT_S16P: {
                //                            int data_size = av_samples_get_buffer_size(frame->linesize, 1, frame->nb_samples, AV_SAMPLE_FMT_S16P, 0);
                //                            fwrite(frame->data[0], 1, data_size, self->file1);
                //                            fwrite(frame->data[1], 1, data_size, self->file2);
                //                        }
                //                            break;
                //                        case AV_SAMPLE_FMT_FLT: {
                //                            int data_size = av_samples_get_buffer_size(frame->linesize, frame->channels, frame->nb_samples, AV_SAMPLE_FMT_FLT, 0);
                //                            fwrite(frame->data[0], 1, data_size, self->file1);
                //                        }
                //                            break;
                //                        case AV_SAMPLE_FMT_FLTP: {
                //                            int data_size = av_samples_get_buffer_size(frame->linesize, 1, frame->nb_samples, AV_SAMPLE_FMT_FLTP, 0);
                //                            fwrite(frame->data[0], 1, data_size, self->file1);
                //                            fwrite(frame->data[1], 1, data_size, self->file2);
                //                        }
                //                            break;
                //                        default:
                //                            break;
                //                    }
                //                    av_frame_free(&frame);
                //                }
                
                
                //                if (ret < 0) {
                //                    NSLog(@"send packet error");
                //                    av_packet_free(&packet);
                //                    [self->timer invalidate];
                //                    return;
                //                }
                //                AVFrame * frame = av_frame_alloc();  //frame->data中存储PCM音频数据
                //                ret = avcodec_receive_frame(self->pAudioCodecCtx, frame);
                //                if (ret < 0) {
                //                    NSLog(@"receive frame error");
                //                    av_frame_free(&frame);
                //                    [self->timer invalidate];
                //                    return;
                //                }
                
                /*
                 pAudioCodecCtx->sample_fmt
                 AV_SAMPLE_FMT_NONE = -1,
                 AV_SAMPLE_FMT_U8,          ///< unsigned 8 bits
                 AV_SAMPLE_FMT_S16,         ///< signed 16 bits
                 AV_SAMPLE_FMT_S32,         ///< signed 32 bits
                 AV_SAMPLE_FMT_FLT,         ///< float
                 AV_SAMPLE_FMT_DBL,         ///< double
                 上面的格式每个声道的数据会以交错方式存储在frame->data[0]中，下面的格式每个声道的数据会分开存储在frame->data[0]~frame->data[i]中
                 AV_SAMPLE_FMT_U8P,         ///< unsigned 8 bits, planar
                 AV_SAMPLE_FMT_S16P,        ///< signed 16 bits, planar
                 AV_SAMPLE_FMT_S32P,        ///< signed 32 bits, planar
                 AV_SAMPLE_FMT_FLTP,        ///< float, planar
                 AV_SAMPLE_FMT_DBLP,        ///< double, planar
                 AV_SAMPLE_FMT_S64,         ///< signed 64 bits
                 AV_SAMPLE_FMT_S64P,        ///< signed 64 bits, planar
                 
                 AV_SAMPLE_FMT_NB           ///< Number of sample formats. DO NOT USE if linking dynamically
                 */
                
                //                AudioStreamBasicDescription streamDescription;
                //                bzero(&streamDescription, sizeof(streamDescription));
                //                streamDescription.mFormatID = kAudioFormatLinearPCM;
                //                streamDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
                //                streamDescription.mSampleRate = 44100.0;
                //                streamDescription.mChannelsPerFrame = self->pAudioCodecCtx->channels;
                //                streamDescription.mFramesPerPacket = 1;
                //                streamDescription.mBitsPerChannel = 16;
                //                streamDescription.mBytesPerFrame = (streamDescription.mBitsPerChannel / 8) * streamDescription.mChannelsPerFrame;
                //                streamDescription.mBytesPerPacket = streamDescription.mBytesPerFrame * streamDescription.mFramesPerPacket;
            }
        } else {
            avcodec_free_context(&self->pCodecCtx);
            avformat_close_input(&self->pFormatCtx);
            avformat_free_context(self->pFormatCtx);
            [self->timer invalidate];
        }
        
    });
}

- (void)initMTL{
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    _commandQueue = [device newCommandQueue];
    id<MTLLibrary> library  = [device newDefaultLibrary];
    id<MTLFunction> function = [library newFunctionWithName:@"yuvToRGB"];
    NSError * error = NULL;
    _pipelineState = [device newComputePipelineStateWithFunction:function error:&error];
    
    CVReturn ret = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &_textCache);
    if (ret != kCVReturnSuccess) {
        NSLog(@"Unable to allocate texture cache");
        return;
    }
    
    self.device = device;
    self.framebufferOnly = NO;
    self.autoResizeDrawable = NO;
}

- (void)decodeAudioData {
    
    
    AVPacket packet;
    av_init_packet(&packet);
    while (av_read_frame(pFormatCtx, &packet) >= 0) {
        if (packet.stream_index == audioIndex) {
            int ret = avcodec_send_packet(pAudioCodecCtx, &packet);
            while (ret >= 0) {
                AVFrame * frame = av_frame_alloc();
                ret = avcodec_receive_frame(pAudioCodecCtx, frame);
                if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
                    break;
                } else if (ret < 0) {
                    NSLog(@"Error during ecoding");
                    break;
                }
                if (filter_graph != NULL) {
                    int retCode = av_buffersrc_add_frame_flags(buffersrc_ctx, frame, 0);
                    if (retCode >= 0) {
                        AVFrame * filt_frame = av_frame_alloc();
                        retCode = av_buffersink_get_frame(buffersink_ctx, filt_frame);
                        frame = av_frame_clone(filt_frame);
                        av_frame_free(&filt_frame);
                    }
                }
                switch (sampleFormat) {
                    case AV_SAMPLE_FMT_S16: {
                        int data_size = av_samples_get_buffer_size(frame->linesize, frame->channels, frame->nb_samples, AV_SAMPLE_FMT_S16, 0);
                        fwrite(frame->data[0], 1, data_size, file1);
                    }
                        break;
                    case AV_SAMPLE_FMT_S16P: {
                        int data_size = av_samples_get_buffer_size(frame->linesize, 1, frame->nb_samples, AV_SAMPLE_FMT_S16P, 0);
                        fwrite(frame->data[0], 1, data_size, file1);
                        fwrite(frame->data[1], 1, data_size, file2);
                    }
                        break;
                    case AV_SAMPLE_FMT_FLT: {
                        int data_size = av_samples_get_buffer_size(frame->linesize, frame->channels, frame->nb_samples, AV_SAMPLE_FMT_FLT, 0);
                        fwrite(frame->data[0], 1, data_size, file1);
                    }
                        break;
                    case AV_SAMPLE_FMT_FLTP: {
                        int data_size = av_samples_get_buffer_size(frame->linesize, 1, frame->nb_samples, AV_SAMPLE_FMT_FLTP, 0);
                        fwrite(frame->data[0], 1, data_size, file1);
                        fwrite(frame->data[1], 1, data_size, file2);
                    }
                        break;
                    default:
                        break;
                }
                av_frame_free(&frame);
            }
        }
    }
    avfilter_free(buffersrc_ctx);
    avfilter_free(buffersink_ctx);
    avfilter_graph_free(&filter_graph);
    buffersrc_ctx = NULL;
    buffersink_ctx = NULL;
    filter_graph = NULL;
    if (file1) {
        fseek(file1, 0, SEEK_SET);
    }
    if (file2) {
        fseek(file2, 0, SEEK_SET);
    }
}

- (void)renderWithPixelBuffer:(CVPixelBufferRef)buffer {
    if (buffer == nil) return;
    CVMetalTextureRef y_texture ;
    //获取pixelbuffer中y数据的宽和高，然后创建包含y数据的MetalTexture，注意pixelformat为MTLPixelFormatR8Unorm
    size_t y_width = CVPixelBufferGetWidthOfPlane(buffer, 0);
    size_t y_height = CVPixelBufferGetHeightOfPlane(buffer, 0);
    CVReturn ret = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textCache, buffer, nil, MTLPixelFormatR8Unorm, y_width, y_height, 0, &y_texture);
    if (ret != kCVReturnSuccess) {
        NSLog(@"fail to create texture");
    }
    id<MTLTexture> y_inputTexture = CVMetalTextureGetTexture(y_texture);
    if (y_inputTexture == nil) {
        NSLog(@"failed to create metal texture");
    }
    
    CVMetalTextureRef uv_texture ;
    //获取pixelbuffer中uv数据的宽和高，然后创建包含uv数据的MetalTexture，注意pixelformat为MTLPixelFormatRG8Unorm
    size_t uv_width = CVPixelBufferGetWidthOfPlane(buffer, 1);
    size_t uv_height = CVPixelBufferGetHeightOfPlane(buffer, 1);
    ret = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textCache, buffer, nil, MTLPixelFormatRG8Unorm, uv_width, uv_height, 1, &uv_texture);
    if (ret != kCVReturnSuccess) {
        NSLog(@"fail to create texture");
    }
    id<MTLTexture> uv_inputTexture = CVMetalTextureGetTexture(uv_texture);
    if (uv_inputTexture == nil) {
        NSLog(@"failed to create metal texture");
    }
    
    CVPixelBufferRelease(buffer);
    CAMetalLayer * metalLayer = (CAMetalLayer *)self.layer;
    id<CAMetalDrawable> drawable = metalLayer.nextDrawable;
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    id<MTLComputeCommandEncoder> computeCommandEncoder = [commandBuffer computeCommandEncoder];
    [computeCommandEncoder setComputePipelineState:_pipelineState];
    //把包含y数据的texture、uv数据的texture和承载渲染图像的texture传入
    [computeCommandEncoder setTexture:y_inputTexture atIndex:0];
    [computeCommandEncoder setTexture:uv_inputTexture atIndex:1];
    [computeCommandEncoder setTexture:drawable.texture atIndex:2];
    MTLSize threadgroupSize = MTLSizeMake(16, 16, 1);
    MTLSize threadgroupCount = MTLSizeMake((y_width  + threadgroupSize.width -  1) / threadgroupSize.width, (y_width + threadgroupSize.height - 1) / threadgroupSize.height, 1);
    [computeCommandEncoder dispatchThreadgroups:threadgroupCount threadsPerThreadgroup: threadgroupSize];
    [computeCommandEncoder endEncoding];
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull cmdBuffer) {
        CVBufferRelease(y_texture);
        CVBufferRelease(uv_texture);
    }];
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
}


// MARK: - private methods
// 当文件被拖动到界面触发
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

- (void)receivedFileUrl:(NSURL *)fileUrl{
    NSLog(@"%@", fileUrl.path);
    
    [self initVideo:fileUrl.path];
}

//当文件在界面中放手
-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    // 判断是否是单文件
    if (zPasteboard.pasteboardItems.count <= 1) {
        NSArray *files = [zPasteboard propertyListForType:NSFilenamesPboardType];
        NSURL *url = [NSURL fileURLWithPath:[files objectAtIndex:0]];
        [self receivedFileUrl:url];
    } else {
        //多文件
        NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
        NSMutableArray *urlList = [NSMutableArray array];
        for (NSString *str in list) {
            NSURL *url = [NSURL fileURLWithPath:str];
            [urlList addObject:url];
        }
    }
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

@end
