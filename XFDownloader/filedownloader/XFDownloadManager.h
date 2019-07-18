//
//  XFDownloadManager.h
//  XFDownloadKit
//
//  Created by yxf on 2017/12/12.
//  Copyright © 2017年 k_yan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFDownloadManager : NSObject

+(instancetype)shareInstance;

+(void)downloadDataFromUrl:(NSString *)url
                  progress:(void(^)(float))progress
                   success:(void(^)(void))success
                      fail:(void(^)(NSError *error))fail;

+(void)cancelTaskWithUrl:(NSString *)url;

+(void)cancelAllTasks;

@end
