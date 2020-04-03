//
//  SMVideoLayer.m
//  smplayer
//
//  Created by midoks on 2020/3/6.
//  Copyright © 2020 midoks. All rights reserved.
//


#import "SMCommon.h"
#import "SMCore.h"

#import "SMVideoLayer.h"

@interface SMVideoLayer()
{
    CGLContextObj _cglContext;
    CGLPixelFormatObj _cglPixelFormat;
}
@end

@implementation SMVideoLayer

-(id)init{
    self = [super init];
    if (self) {
        [self setAsynchronous:NO];
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

        
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
        
        self.backgroundColor = [NSColor blackColor].CGColor;
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
    
    [[[SMCore Instance] player].uninitLock lock];
    
    BOOL result = [[[SMCore Instance] player].mpv shouldRenderUpdateFrame];
    [[[SMCore Instance] player].uninitLock unlock];
    
    return result;
}

- (void)drawInCGLContext:(CGLContextObj)ctx pixelFormat:(CGLPixelFormatObj)pf forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts {
    
    [[[SMCore Instance] player].uninitLock lock];
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
    
    mpv_render_context_render([[SMCore Instance] player].mpv.context, params);
    CGLFlushDrawable(_cglContext);
 
    [[[SMCore Instance] player].uninitLock unlock];
}

- (CGLContextObj)copyCGLContextForPixelFormat:(CGLPixelFormatObj)pf {
    return _cglContext;
}

-(void) display {
    [super display];
    [CATransaction flush];
}


@end
