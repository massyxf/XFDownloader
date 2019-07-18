//
//  XFFileTool.h
//  XFDownloadKit
//
//  Created by yxf on 2017/12/8.
//  Copyright © 2017年 k_yan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFFileTool : NSObject

//判断文件类别
+(BOOL)directoryExistAtPath:(NSString *)path;

+(BOOL)fileExistAtPath:(NSString *)filepath;

//文件目录
+(NSString *)fileDownloadingPathWithUrl:(NSString *)url;

+(NSString *)fileDownloadedPathWithUrl:(NSString *)url;

//文件信息
+(long long)filesizeAtPath:(NSString *)path;

+(NSString *)contentTypeWithURL:(NSString *)url;

//文件操作
+(void)deleteFileAtPath:(NSString *)path;

+(void)moveItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath;

@end
