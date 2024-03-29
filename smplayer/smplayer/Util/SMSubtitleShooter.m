//
//  SMSubtitleShooter.m
//  smplayer
//
//  Created by midoks on 2020/3/26.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "NSData+MD5.h"
#import "AFNetworking.h"

#import "SMSubtitleShooter.h"
@interface SMSubtitleShooter()
{
    NSString *apiPath;
    AFHTTPSessionManager *manager;
}
@end

@implementation SMSubtitleShooter

static SMSubtitleShooter *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[SMSubtitleShooter alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [super init];
    if(self){
        /**
         *  https://www.shooter.cn
         *  https://docs.google.com/document/d/1ufdzy6jbornkXxsD-OGl3kgWa4P9WO5NZb6_QYZiGI0/preview#
         */
        apiPath = @"https://www.shooter.cn/api/subapi.php";
        
        manager = [AFHTTPSessionManager manager];
        //        NSString *info = [NSString stringWithFormat:@"smplayer client/%@(midoks@163.com)",[[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        //        [manager setValue:info forKey:@"User-Agent"];
    }
    return self;
}

-(NSDictionary*)hash:(NSURL *)url{
    NSFileHandle * file =  [NSFileHandle fileHandleForReadingAtPath:[url path]];
    [file seekToEndOfFile];
    NSInteger fileSize = [file offsetInFile];
    
    if ( fileSize <= 12288){
        return @{};
    }
    
    NSArray *offsets = @[
        @4096,
        @(fileSize/3*2),
        @(fileSize/3),
        @(fileSize - 8192),
    ];
    
    NSMutableString *fileHash = [NSMutableString string];
    
    for (int i = 0; i< [offsets count]; i++) {
        NSInteger offset = [[offsets objectAtIndex:i] integerValue];
        [file seekToFileOffset:offset];
        NSString *tmp = [[file readDataOfLength:4096] getMD5Data];
        if (i == [offsets count] - 1){
            [fileHash appendFormat:@"%@", tmp];
        } else {
            [fileHash appendFormat:@"%@;", tmp];
        }
    }
    
    NSDictionary *reqInfoData = @{
        @"filehash" : fileHash,
        @"pathinfo": [url path],
        @"format" : @"json",
        @"lang" : @"chn",
    };
    [file closeFile];
    return reqInfoData;
}

-(void)request:(NSURL *)url
      callback:(void(^)(NSUInteger index, NSURL *path))callback
{
    if([[url path] isEqualToString:@""]){
        return;
    }
    
    NSDictionary *reqInfoData = [self hash:url];
//    NSLog(@"url:%@\nargs:%@", url, reqInfoData);
    [manager POST:apiPath parameters:reqInfoData progress:^(NSProgress * uploadProgress) {
    } success:^(NSURLSessionDataTask * task, id responseObject) {
        NSArray *data = responseObject;
        NSUInteger count = [data count];

        for (NSUInteger i=0; i<count; i++) {
            NSDictionary *info =  [responseObject objectAtIndex:i];
            NSString *downloadURL = [[[info objectForKey:@"Files"] objectAtIndex:0] objectForKey:@"Link"];
            NSString *extName = [[[info objectForKey:@"Files"] objectAtIndex:0] objectForKey:@"Ext"];
            [self download:downloadURL path:url index:i+1 extName:extName callback:callback];
        }
        
    } failure:^(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"error:%@", [error localizedDescription]);
    }];
}

-(void)download:(NSString *)url
           path:(NSURL *)pathURL
          index:(NSInteger)index
        extName:(NSString *)extName
       callback:(void(^)(NSUInteger index, NSURL *path))callback
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/octet-stream"];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
    
        NSString *fileName;
        fileName = [pathURL.lastPathComponent stringByReplacingOccurrencesOfString:pathURL.pathExtension
                                                                        withString:extName];

        fileName = [NSString stringWithFormat:@"[%ld]%@", index, fileName];
        NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                    inDomain:NSUserDomainMask
                                                           appropriateForURL:nil
                                                                      create:YES
                                                                       error:nil];

        return [downloadURL URLByAppendingPathComponent:fileName];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        callback(index, filePath);
    }];
    [downloadTask resume];
}

@end
