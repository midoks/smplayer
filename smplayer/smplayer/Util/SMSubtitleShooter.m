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

-(void)request:(NSURL *)url{
    NSDictionary *reqInfoData = [self hash:url];
    
    NSLog(@"reqInfoData:%@", reqInfoData );
    
    [manager POST:apiPath parameters:reqInfoData progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * task, id responseObject) {
        NSArray *tmp = responseObject;
        
        NSLog(@"%ld,",[tmp count]);
        
        
        NSDictionary *info =  [responseObject objectAtIndex:0];
        NSLog(@"%@,",[[[info objectForKey:@"Files"] objectAtIndex:0] objectForKey:@"Link"]);
        
        NSString *url = [[[info objectForKey:@"Files"] objectAtIndex:0] objectForKey:@"Link"];
        
        [self down2:url];
        
    } failure:^(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"error:%@",error);
    }];
}

-(void)download:(NSString*)url{
    AFHTTPSessionManager *ownManager = [AFHTTPSessionManager manager];
    //    ownManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        ownManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    ownManager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/octet-stream",nil];
    [ownManager GET:url parameters:nil progress:^(NSProgress * downloadProgress) {
        
    } success:^(NSURLSessionDataTask * task, id responseObject) {
        NSLog(@"ok:%@", responseObject);
        
        NSData *data =[responseObject dataUsingEncoding:NSUTF8StringEncoding];
        NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
//        NSString * str = [self convertDataToHexStr:responseObject];
        
        NSLog(@"ok:%@", str);
    } failure:^(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"ee:%@", error);
    }];
}

-(void)down2:(NSString *)url{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
//    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    [request setValue:@"utf-8" forKey:@"charset"];
    
    NSLog(@"%@", [request allHTTPHeaderFields]);
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSLog(@"w:%@",response);
        NSLog(@"ee:%@:%@",targetPath,[response suggestedFilename]);
   
    
        NSString *fileName = [response suggestedFilename];
//        fileName = [self replaceUnicode:fileName];
        fileName = [NSString stringWithFormat:@"[%d]%@", 1, fileName];

        
        //        NSLog(@"dd:%@", [response textEncodingName]);
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        fileName = [[NSString alloc] initWithCString:fileName.UTF8String encoding:encoding];
        NSLog(@"pp:%@",fileName);
//        fileName = [self conv:fileName];
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:fileName];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
}

-(void)down3:(NSString *)url{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    manager.responseSerializer = [[NSSet alloc] initWithObjects:@"application/octet-stream",nil];
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    

    NSURLSessionDataTask *dataTask=[manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {

    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
}

-(NSString *)replaceUnicode:(NSString *)unicodeStr {
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* returnStr = [NSPropertyListSerialization propertyListWithData:tempData
                                              options:NSPropertyListImmutable
                                               format:NULL
                                                error:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\n"];
}

-(NSString*)conv:(NSString*)keyString{
    NSMutableString *keyWord = [NSMutableString stringWithFormat:@""];
    for (int i=0; i<[keyString length]; i++) {
        NSUInteger location = i;
        unichar temp = [keyString characterAtIndex:location];
        
        NSString *str = [NSString stringWithFormat: @"%C", temp];
        NSString *str2 = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [keyWord appendString:str2];
        //        [keyWord appendString:@";"];
    }
    return keyWord;
}

-(NSString *)convertDataToHexStr:(NSData *)data{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

@end
