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
@end

@implementation SMVideoView

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.wantsLayer =YES;
        self.layer.backgroundColor = [NSColor brownColor].CGColor;
        
        NSString *filename = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"mp4"];
        [self initVideo:filename];
        // 注册文件拖动事件
//        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

}

-(void) initMenu{
    NSMenu *m = [[NSMenu alloc] initWithTitle:@"AMainMenu"];
    NSMenuItem *item = [m addItemWithTitle:@"Apple" action:nil keyEquivalent:@""];
    NSMenu *sm = [[NSMenu alloc] initWithTitle:@"Apple"];
    [m setSubmenu:sm forItem:item];
    [sm addItemWithTitle: @"mpv_command('stop')" action:@selector(mpv_stop) keyEquivalent:@""];
    [sm addItemWithTitle: @"mpv_command('quit')" action:@selector(mpv_quit) keyEquivalent:@""];
    [sm addItemWithTitle: @"quit" action:@selector(terminate:) keyEquivalent:@"q"];
    [NSApp setMenu:m];
    [NSApp activateIgnoringOtherApps:YES];
}

-(void) initVideo:(NSString *)path{

    wrapper = [[NSView alloc] initWithFrame:self.frame];
    [wrapper setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [self addSubview:wrapper];
    
    // Deal with MPV in the background.
    queue = dispatch_queue_create("mpv", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        
        self->mpv = mpv_create();
        if (!self->mpv) {
            NSLog(@"%@", @"failed creating context");
            exit(-1);
        }
        
        int64_t wid = (intptr_t) self->wrapper;
        check_error(mpv_set_option(self->mpv, "wid", MPV_FORMAT_INT64, &wid));
        
        // Maybe set some options here, like default key bindings.
        // NOTE: Interaction with the window seems to be broken for now.
        //        check_error(mpv_set_option_string(self->mpv, "input-default-bindings", "yes"));
        
        //        // for testing!
        //        check_error(mpv_set_option_string(self->mpv, "input-media-keys", "yes"));
        //        check_error(mpv_set_option_string(self->mpv, "input-cursor", "no"));
        //        check_error(mpv_set_option_string(self->mpv, "input-vo-keyboard", "yes"));
        
        // request important errors
        //        check_error(mpv_request_log_messages(self->mpv, "warn"));
        
        check_error(mpv_initialize(self->mpv));
        
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
            if (event->event_id == MPV_EVENT_NONE)
                break;
            [self handleEvent:event];
        }
    });
}

static void wakeup(void *context) {
    SMVideoView *a = (__bridge SMVideoView *) context;
    [a readEvents];
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


@end
