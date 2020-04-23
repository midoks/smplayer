//
//  RecordScreen.m
//  smplayer
//
//  Created by midoks on 2020/4/12.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "RecordScreen.h"



@interface RecordScreen ()
{
    CGDirectDisplayID           display;
    AVCaptureMovieFileOutput    *captureMovieFileOutput;
    NSMutableArray              *shadeWindows;
}

@property (weak) IBOutlet  NSView *contentView;

@property (strong,nonatomic) AVCaptureSession *captureSession;
@property (strong) AVCaptureScreenInput *captureScreenInput;

@end

@implementation RecordScreen

-(id)init{
    self = [self initWithWindowNibName:@"RecordScreen"];
    return self;
}

static RecordScreen *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[RecordScreen alloc] init];
    });
    return _instance;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.movableByWindowBackground = YES;
    self.contentView.layer.cornerRadius = 5;
    
    self.captureSession = [[AVCaptureSession alloc] init];
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]){
        [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    }
    
    /* Add the main display as a capture input. */
    display = CGMainDisplayID();
    self.captureScreenInput = [[AVCaptureScreenInput alloc] initWithDisplayID:display];
    
    if ([self.captureSession canAddInput:self.captureScreenInput]){
        [self.captureSession addInput:self.captureScreenInput];
    }
    
    
    /* Add a movie file output + delegate. */
    captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    [captureMovieFileOutput setDelegate:self];
    if ([self.captureSession canAddOutput:captureMovieFileOutput])
    {
        [self.captureSession addOutput:captureMovieFileOutput];
    }
}


#pragma mark - AVCaptureFileOutputDelegate
- (BOOL)captureOutputShouldProvideSampleAccurateRecordingStart:(nonnull AVCaptureOutput *)output {
    return NO;
}

- (void)captureOutput:(nonnull AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(nonnull NSURL *)outputFileURL fromConnections:(nonnull NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    
}

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    
}

#pragma mark - Public Methods
-(IBAction)winClose:(id)sender{
    NSLog(@"close this window");
    [self.window close];
}

-(IBAction)startRecording:(id)sender{
    NSLog(@"start");
}



@end
