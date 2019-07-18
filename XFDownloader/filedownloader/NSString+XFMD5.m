//
//  NSString+XFMD5.m
//  XFDownloadKit
//
//  Created by yxf on 2017/12/12.
//  Copyright © 2017年 k_yan. All rights reserved.
//

#import "NSString+XFMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (XFMD5)

-(NSString *)xf_md5{
    const char *data = self.UTF8String;
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    
    //把c语言的字符串 -> md5 c字符串
    CC_MD5(data, (CC_LONG)strlen(data), md);
    
    // 32
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x",md[i]];
    }
    
    return result;
}

@end
