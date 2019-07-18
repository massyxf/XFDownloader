//
//  XFDownloadRequest.h
//  XFDownloadKit
//
//  Created by yxf on 2017/12/8.
//  Copyright © 2017年 k_yan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, XFDownloadRequestStatus) {
    XFDownloadRequestDefault = 0,///默认状态，等待开始下载
    XFDownloadRequestDownloading,///正在下载
    XFDownloadRequestPause,///暂停
    XFDownloadRequestDownloaded,///已经下载成功
    XFDownloadRequestDownloadFailed///下载失败
};

@interface XFDownloadRequest : NSObject
/* 下载状态 */
@property (nonatomic,assign,readonly)XFDownloadRequestStatus status;

/* 下载进度 */
@property (nonatomic,assign,readonly)float progress;

@property (nonatomic,copy,readonly)NSString *url;

-(instancetype)initWithUrl:(NSString *)url
                  progress:(void(^)(float))progress
                   success:(void(^)(void))success
                      fail:(void(^)(NSError *error))fail;

-(void)startDownload;

//取消下载
-(void)cancelDownload;

//暂停下载
-(void)pauseDownload;

//继续下载
-(void)resumeDownload;

@end
