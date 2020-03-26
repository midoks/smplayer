//
//  NSData+MD5.m
//  smplayer
//
//  Created by midoks on 2020/3/26.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "NSData+MD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (MD5)

-(NSString *)getMD5Data{
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    CC_MD5_Update(&md5, self.bytes, (CC_LONG)self.length);
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(result, &md5);
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X", result[i]];
    }
    return resultString;
}

@end
