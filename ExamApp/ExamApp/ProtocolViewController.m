//
//  ProtocolViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/29.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ProtocolViewController.h"
#import "UIViewController+VisibleView.h"
#import "ETextView.h"

#define __k_protocol_marign_top 10//顶部间距
#define __k_protocol_margin_left 12//左边间距
#define __k_protocol_margin_right 12//右边间距
#define __k_protocol_margin_bottom 20//底部间距

#define __k_protocol_replace_source "COMPANY_NAME"//替换源
#define __k_protocol_replace_target "［中华考试网］"//替换目标
//隐私协议控制器成员变量
@interface ProtocolViewController (){
    ETextView *_contentView;
}
@end
//隐私协议控制器实现类
@implementation ProtocolViewController
#pragma mark 程序入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //兼容继承于UIScrollView的控件在navigationbar容器中出现顶部空白的问题
    if([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]){
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //初始化内容容器
    CGRect tempFrame = [self loadVisibleViewFrame];
    tempFrame.origin.x += __k_protocol_margin_left;
    tempFrame.origin.y += __k_protocol_marign_top;
    tempFrame.size.width -= (__k_protocol_margin_left + __k_protocol_margin_right);
    tempFrame.size.height -= (__k_protocol_marign_top + __k_protocol_margin_bottom);
    
    NSString *text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"privacy" ofType:nil] encoding:NSUTF8StringEncoding error:nil];
    
    _contentView = [[ETextView alloc] initWithFrame:tempFrame];
    _contentView.editable = NO;
    _contentView.text = [text stringByReplacingOccurrencesOfString:@__k_protocol_replace_source withString:@__k_protocol_replace_target];
    [self.view addSubview:_contentView];
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
