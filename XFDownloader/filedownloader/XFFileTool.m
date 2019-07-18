//
//  XFFileTool.m
//  XFDownloadKit
//
//  Created by yxf on 2017/12/8.
//  Copyright © 2017年 k_yan. All rights reserved.
//

#import "XFFileTool.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define DirName @"xffile"

@implementation XFFileTool

+(BOOL)fileExistAtPath:(NSString *)filepath{
    return [[NSFileManager defaultManager] fileExistsAtPath:filepath];
}

+(BOOL)directoryExistAtPath:(NSString *)path{
    BOOL isDirecroty = NO;
    BOOL isFileExsit = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirecroty];
    return isFileExsit && isDirecroty;
}

+(NSString *)fileDownloadingPathWithUrl:(NSString *)url{
    NSString *tempDir = NSTemporaryDirectory();
    return [tempDir stringByAppendingPathComponent:url.lastPathComponent];
}

+(NSString *)fileDownloadedPathWithUrl:(NSString *)url{
    NSString *libDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject;
    NSString *dirPath = [libDir stringByAppendingPathComponent:DirName];
    
    if (![self directoryExistAtPath:dirPath]) {
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!success) {
            NSLog(@"create file error:%@",error);
            return nil;
        }
    }
    
    return [dirPath stringByAppendingPathComponent:url.lastPathComponent];
}

+(long long)filesizeAtPath:(NSString *)path{
    if (![self fileExistAtPath:path]) {
        return 0;
    }
    NSError *error = nil;
    NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    long long size = [fileInfo[NSFileSize] longLongValue];
    return size;
}

+(NSString *)contentTypeWithURL:(NSString *)url{
    NSString *fileExtension = url.pathExtension;
    
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    
    return contentType;
}

+(void)deleteFileAtPath:(NSString *)path{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

+(void)moveItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath{
    [[NSFileManager defaultManager] moveItemAtPath:fromPath toPath:toPath error:nil];
}

@end
