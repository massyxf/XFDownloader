//
//  XFDownloadRequest.m
//  XFDownloadKit
//
//  Created by yxf on 2017/12/8.
//  Copyright © 2017年 k_yan. All rights reserved.
//

#import "XFDownloadRequest.h"
#import "XFFileTool.h"

@interface XFDownloadRequest ()<NSURLSessionDataDelegate>

@property (nonatomic,copy)NSString *downloadingPath;

@property (nonatomic,copy)NSString *downloadedPath;

/*session*/
@property (nonatomic,strong)NSURLSession *session;

/*write*/
@property (nonatomic,strong)NSOutputStream *stream;

/*task*/
@property (nonatomic,weak)NSURLSessionTask *task;

/*status*/
@property (nonatomic,assign)XFDownloadRequestStatus status;

/*loaded size*/
@property (nonatomic,assign)long long loadedSize;

/*file size*/
@property (nonatomic,assign)long long fileSize;

/*success block*/
@property (nonatomic,copy)void (^successBlock)(void);

/*fail block*/
@property (nonatomic,copy)void (^failBlock)(NSError *error);

/*progress block*/
@property (nonatomic,copy)void (^progressBlock)(float);

/*url*/
@property (nonatomic,copy)NSString *url;

@end

@implementation XFDownloadRequest

-(instancetype)init{
    if (self = [super init]) {
        self.status = XFDownloadRequestDefault;
        self.loadedSize = 0;
        self.fileSize = 0;
    }
    return self;
}

-(instancetype)initWithUrl:(NSString *)url progress:(void (^)(float))progress success:(void (^)(void))success fail:(void (^)(NSError *))fail{
    if (self = [super init]) {
        self.url = url;
        self.downloadingPath = [XFFileTool fileDownloadingPathWithUrl:url];
        self.downloadedPath = [XFFileTool fileDownloadedPathWithUrl:url];
        self.progressBlock = progress;
        self.successBlock = success;
        self.failBlock = fail;
    }
    return self;
}

#pragma mark - getter
-(NSURLSession *)session{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *queue = [NSOperationQueue currentQueue];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
    }
    return _session;
}

-(NSOutputStream *)stream{
    if (!_stream) {
        _stream = [NSOutputStream outputStreamToFileAtPath:self.downloadingPath append:YES];
    }
    return _stream;
}

-(float)progress{
    return self.fileSize > 0 ? 1.0 * self.loadedSize / self.fileSize : 0;
}

#pragma mark - public func
-(void)startDownload{
    if (self.url.length > 0){
        
        if ([XFFileTool fileExistAtPath:self.downloadedPath]){//已下载完成
            NSLog(@"已下载完成");
            [self downloadSuccess];
            return ;
        }
        if ([XFFileTool fileExistAtPath:self.downloadingPath]) {
            self.loadedSize = [XFFileTool filesizeAtPath:self.downloadingPath];
        }
        
        //没有下载过，从0开始下载
        [self downloadFileAtUrl:self.url offset:self.loadedSize];
    }
}

-(void)cancelDownload{
    [self.session invalidateAndCancel];
    self.session = nil;
    self.status = XFDownloadRequestDefault;
    self.loadedSize = 0;
}

-(void)pauseDownload{
    [self.task suspend];
    self.status = XFDownloadRequestPause;
}

-(void)resumeDownload{
    [self.task resume];
    self.status = XFDownloadRequestDownloading;
}

#pragma mark - custom func
-(void)downloadFileAtUrl:(NSString *)url offset:(long long)offset{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",offset] forHTTPHeaderField:@"Range"];
    _task = [self.session dataTaskWithRequest:request];
    [self resumeDownload];
}

#pragma mark - status control
-(void)downloadSuccess{
    if (self.successBlock) {
        self.successBlock();
    }
    self.status = XFDownloadRequestDownloaded;
}

-(void)downloadFail:(NSError *)error{
    if (self.failBlock) {
        self.failBlock(error);
    }
    self.status = XFDownloadRequestDownloadFailed;
}

#pragma mark - NSURLSessionDataDelegate
//获得响应
-(void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSHTTPURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler{
    //1.获取缓存大小
    _fileSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *range = response.allHeaderFields[@"Content-Range"];
    if (range.length > 0) {
        _fileSize = [[range componentsSeparatedByString:@"/"].lastObject longLongValue];
    }
    
    //2.比较下载文件和实际文件大小
    if (self.loadedSize < _fileSize) {
        //2.1继续下载
        [self.stream open];
        completionHandler(NSURLSessionResponseAllow);
    } else{
        //2.2文件下载有误,删除原文件，重新下载
        [XFFileTool deleteFileAtPath:self.downloadingPath];
        completionHandler(NSURLSessionResponseCancel);
        [self startDownload];
    }
}

//接收数据
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    self.loadedSize += data.length;
    if(self.progressBlock){
        self.progressBlock(self.progress);
    }
    [self.stream write:data.bytes maxLength:data.length];
}

//下载完成
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    //停止文件写入
    [self.stream close];
    
    if (error == nil) {
        [XFFileTool moveItemAtPath:self.downloadingPath toPath:self.downloadedPath];
        //⚠️:下载成功之后最好做下文件正确性验证
        [self downloadSuccess];
    }else if (error.code == NSURLErrorCancelled){
        NSLog(@"取消下载");
        [self cancelDownload];
    }else{
        NSLog(@"下载失败");
        [self downloadFail:error];
    }
}

@end
