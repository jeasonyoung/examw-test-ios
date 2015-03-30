//
//  WebViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "WebViewController.h"

#import "WaitForAnimation.h"

#define __kWebViewController_error_btn_title @"ok"
#define __kWebViewController_waiting @"正在加载..."
//访问网页视图控制器成员变量
@interface WebViewController ()<UIWebViewDelegate>{
    NSString *_url;
    WaitForAnimation *_waitFor;
}
@end
//访问网页视图控制器实现
@implementation WebViewController
#pragma mark 初始化
-(instancetype)initWithURL:(NSString *)url{
    if(self = [super init]){
        _url =  url;
    }
    return self;
}
#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.frame];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    if(_url && _url.length > 0){
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    }
    [self.view addSubview:webView];
}

#pragma mark UIWebViewDelegate
//开始加载
-(void)webViewDidStartLoad:(UIWebView *)webView{
    _waitFor = [[WaitForAnimation alloc]initWithView:self.view WaitTitle:__kWebViewController_waiting];
    [_waitFor show];
}
//加载完成
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if(_waitFor){
        [_waitFor hide];
    }
}
//加载出错
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if(_waitFor){
        [_waitFor hide];
    }
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@""
                                                   message:[error localizedDescription]
                                                  delegate:nil
                                         cancelButtonTitle:nil
                                         otherButtonTitles:__kWebViewController_error_btn_title, nil];
    [alter show];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
