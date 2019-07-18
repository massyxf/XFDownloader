//
//  ViewController.m
//  XFDownloader
//
//  Created by yxf on 2019/7/18.
//  Copyright © 2019 k_yan. All rights reserved.
//

#import "ViewController.h"
#import "XFDownloadManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSString *img = @"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a";
    [XFDownloadManager downloadDataFromUrl:img progress:^(float progress) {
        NSLog(@"progress:%f",progress);
    } success:^{
        NSLog(@"下载成功");
    } fail:^(NSError *error) {
        NSLog(@"下载失败");
    }];
}


@end
