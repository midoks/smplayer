//
//  Welcome.m
//  smplayer
//
//  Created by midoks on 2020/3/7.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "Welcome.h"
#import "SMCore.h"
#import "OpenFileView.h"
#import "SMCommon.h"
#import "SMVideoTime.h"
#import "Preference.h"
#import "OpenURL.h"


@interface Welcome () <NSWindowDelegate,NSTableViewDelegate,NSTableViewDataSource,OpenFileViewDelegate>

@property (weak) IBOutlet NSView *mainView;
@property (weak) IBOutlet NSTextField *version;
@property (weak) IBOutlet NSVisualEffectView *visualEffectView;

@property (weak) IBOutlet OpenFileView *openFileView;
@property (weak) IBOutlet OpenFileView *openFileUrlView;
@property (weak) IBOutlet OpenFileView *lastFileView;
@property (weak) IBOutlet NSImageView *lastFileIcon;
@property (weak) IBOutlet NSTextField *lastResumeLabel;
@property (weak) IBOutlet NSTextField *lastFileNameLabel;
@property (weak) IBOutlet NSTextField *lastFilePosLabel;


@property (weak) IBOutlet NSTableView *recentFilesTableView;


@property (readonly, copy) NSArray<NSURL *> *recentDocumentURLs;
@property NSString *currentFilePath;
@property double currentFilePos;

@end

@implementation Welcome

-(id)init{
    self = [self initWithWindowNibName:@"Welcome"];
    return self;
}

static Welcome *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[Welcome alloc] init];
    });
    return _instance;
}

-(id)initWithWindow:(NSWindow *)window
{
    if (self = [super initWithWindow:window]) {
        [self loadWindow];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.movableByWindowBackground = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    
    // Drag File
    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
    self.window.appearance =  [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    
    self.mainView.wantsLayer = YES;
    self.mainView.layer.backgroundColor = CGColorCreateGenericGray(0.5, 0.1);
    
    self.visualEffectView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    self.lastFileIcon.image = [NSImage imageNamed:@"history"];
    
    [self.version setStringValue:[[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    _openFileView.delegate = self;
    _openFileUrlView.delegate = self;
    _lastFileView.delegate = self;
    
    
    [self initRecentTableView];
    
    [self updateLastPlayInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:SM_NOTIF_FILELOADED object:nil];
}

-(void)initRecentTableView{
    _recentDocumentURLs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
    
    self.recentFilesTableView.delegate = self;
    self.recentFilesTableView.dataSource = self;
    
    self.recentFilesTableView.gridColor = [NSColor magentaColor];
    [self.recentFilesTableView reloadData];
}

-(void)updateLastPlayInfo{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    _currentFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:SM_FILE_PATH];
    _currentFilePos = [[NSUserDefaults standardUserDefaults] doubleForKey:SM_FILE_POS];
    
    if ([fm fileExistsAtPath:_currentFilePath]){
        NSURL *url = [NSURL fileURLWithPath:_currentFilePath isDirectory:NO];
        SMVideoTime *time = [[SMVideoTime alloc] initTime:_currentFilePos];
        
        [self.lastFileNameLabel setStringValue:url.lastPathComponent];
        [self.lastFilePosLabel setStringValue:[time getString]];
        self.lastFileView.hidden = NO;
    } else {
        [self.lastFileNameLabel setStringValue:@"demo.mp4"];
        [self.lastFilePosLabel setStringValue:@"10:20"];
        self.lastFileView.hidden = YES;
    }
}

-(void)reloadData{
    _recentDocumentURLs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
    [self.recentFilesTableView reloadData];
    
    [self updateLastPlayInfo];
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [_recentDocumentURLs count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSURL *url = _recentDocumentURLs[row];
    return @{
        @"url":url.lastPathComponent,
        @"image": [[NSWorkspace sharedWorkspace] iconForFile:url.path]
    };
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 28;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    NSInteger row = _recentFilesTableView.selectedRow;
    if (row>=0){
        NSURL *url = _recentDocumentURLs[row];
        [[[SMCore Instance] player] showWindow:self];
        [[[SMCore Instance] player] openVideo:[url path]];
        [[[SMCore Instance] first] close];
    }
    [_recentFilesTableView deselectAll:self];
}

#pragma mark - Private Method Of Drag File
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    NSArray *files = [zPasteboard propertyListForType:NSFilenamesPboardType];
    
    [[NSApp delegate] application:[NSApplication sharedApplication] openFile:[files objectAtIndex:0]];
    return YES;
}

#pragma mark - OpenFileViewDelegate
-(void)openFileMouseDown:(NSString *)identifier{
    
    if ([identifier isEqualToString:@"open-file"]){
        
        [[[SMCore Instance] player] openSelectVideo:^{
            [[[SMCore Instance] first] close];
        }];
    
    } else if ([identifier isEqualToString:@"open-fileurl"]){
        [[OpenURL Instance] showWindow:self];
    } else if ([identifier isEqualToString:@"open-resume"]){

        [[[SMCore Instance] player] showWindow:self];
        [[[SMCore Instance] player] openVideo:_currentFilePath seek:_currentFilePos];
        [[[SMCore Instance] first] close];
    }
}

-(void)openFileMouseUp:(NSString *)identifier{
}

#pragma mark - NSWindowDelegate
-(void)windowDidBecomeKey:(NSNotification *)notification{
    [self reloadData];
}

@end
