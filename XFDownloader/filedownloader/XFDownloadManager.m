//
//  XFDownloadManager.m
//  XFDownloadKit
//
//  Created by yxf on 2017/12/12.
//  Copyright © 2017年 k_yan. All rights reserved.
//

#import "XFDownloadManager.h"
#import "XFDownloadRequest.h"
#import "NSString+XFMD5.h"

static const NSInteger xf_max_requests = 4;

@interface XFDownloadManager ()<NSCopying,NSMutableCopying>

/*url : request dict*/
@property (nonatomic,strong)NSMutableDictionary *requestDict;

/*cache*/
@property (nonatomic,strong)NSMutableArray<XFDownloadRequest *> *cacheRequests;

@end

@implementation XFDownloadManager

#pragma mark - initial

static XFDownloadManager *_manager = nil;

+(instancetype)shareInstance{
    if(!_manager){
        _manager = [[self alloc] init];
    }
    return _manager;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _manager = [super allocWithZone:zone];
        });
    }
    return _manager;
}

-(id)copyWithZone:(NSZone *)zone{
    return _manager;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return _manager;
}

#pragma mark - getter
-(NSMutableDictionary *)requestDict{
    if(!_requestDict){
        _requestDict = [NSMutableDictionary dictionary];
    }
    return _requestDict;
}

-(NSMutableArray<XFDownloadRequest *> *)cacheRequests{
    if (!_cacheRequests) {
        _cacheRequests = [NSMutableArray array];
    }
    return _cacheRequests;
}

#pragma mark - public func
+(void)downloadDataFromUrl:(NSString *)url progress:(void (^)(float))progressBlock success:(void (^)(void))success fail:(void (^)(NSError *))fail{
    XFDownloadManager *manager = [self shareInstance];
    //0.检查请求数
    @synchronized(manager.requestDict) {
        XFDownloadRequest *request = manager.requestDict[url.xf_md5];
        if (!request) {
            request = [manager createRequestWithUrl:url progress:progressBlock success:success fail:fail];
        }
        
        //0.1超过最大请求数，缓存
        if ([manager isReachMaxRequests]) {
            [manager.cacheRequests addObject:request];
            return;
        }
        
        //开始请求
        manager.requestDict[url.xf_md5] = request;
        [manager downloadRequest:request];
    }
}

+(void)cancelTaskWithUrl:(NSString *)url{
    XFDownloadManager *manager = [self shareInstance];
    XFDownloadRequest *request = manager.requestDict[url.xf_md5];
    [request cancelDownload];
}

+(void)cancelAllTasks{
    XFDownloadManager *manager = [self shareInstance];
    [manager.requestDict.allValues performSelector:@selector(cancelDownload)];
}

#pragma mark - custom func
-(XFDownloadRequest *)createRequestWithUrl:(NSString *)url progress:(void (^)(float))progressBlock success:(void (^)(void))success fail:(void (^)(NSError *))fail{
    __weak typeof(self) weakManager = self;
    return [[XFDownloadRequest alloc] initWithUrl:url progress:^(float progress) {
        if(progressBlock){
            progressBlock(progress);
        }
    } success:^{
        [weakManager completeWithUrl:url];
        if (success) {
            success();
        }
        
    } fail:^(NSError *error) {
        [weakManager completeWithUrl:url];
        if (fail) {
            fail(error);
        }
    }];
}

-(void)downloadRequest:(XFDownloadRequest *)request{
    //1.1正在下载
    if (request.status == XFDownloadRequestDownloading) {
        return ;
    }
    //1.2挂起状态
    if (request.status == XFDownloadRequestPause) {
        [request resumeDownload];
        return ;
    }
    [request startDownload];
}

-(BOOL)isReachMaxRequests{
    return self.requestDict.allValues.count > xf_max_requests;
}

-(void)completeWithUrl:(NSString *)url{
    @synchronized(self.requestDict) {
        [self.requestDict removeObjectForKey:url.xf_md5];
        //开始另一个下载
        if (self.cacheRequests.count > 0) {
            XFDownloadRequest *request = self.cacheRequests.firstObject;
            self.requestDict[request.url.xf_md5] = request;
            [self.cacheRequests removeObject:request];
            [self downloadRequest:request];
        }
    }
}

@end
