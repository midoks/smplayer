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

@interface Welcome () <NSWindowDelegate,NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSView *mainView;

@property (weak) IBOutlet NSTextField *version;

@property (weak) IBOutlet NSVisualEffectView *visualEffectView;

@property (weak) IBOutlet OpenFileView *lastFileView;
@property (weak) IBOutlet NSImageView *lastFileIcon;
@property (weak) IBOutlet NSTextField *lastFileNameLabel;
@property (weak) IBOutlet NSTextField *lastFilePosLabel;

@property (weak) IBOutlet NSTableView *recentFilesTableView;

@property (readonly, copy) NSArray<NSURL *> *recentDocumentURLs;

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
    
    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
    self.window.appearance =  [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    
    self.mainView.wantsLayer = YES;
    self.mainView.layer.backgroundColor = CGColorCreateGenericGray(0.5, 0.1);
    
    self.visualEffectView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    self.lastFileIcon.image = [NSImage imageNamed:@"history"];

    [self.lastFileNameLabel setStringValue:@"demo.mp4"];
    [self.lastFilePosLabel setStringValue:@"10:20"];
    
    
    [self.version setStringValue:[[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];

    [self initRecentTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:SM_NOTIF_FILELOADED object:nil];
}

-(void)initRecentTableView{
    _recentDocumentURLs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];

    self.recentFilesTableView.delegate = self;
    self.recentFilesTableView.dataSource = self;
    
    self.recentFilesTableView.gridColor = [NSColor magentaColor];
    [self.recentFilesTableView reloadData];
}

-(void)reloadData{
    _recentDocumentURLs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
    [self.recentFilesTableView reloadData];
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

#pragma mark - NSWindowDelegate
//-(void)windowWillClose:(NSNotification *)notification{
//    NSLog(@"windowWillClose");
//}

@end
