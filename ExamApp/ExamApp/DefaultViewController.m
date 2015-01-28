//
//  DefaultViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "DefaultViewController.h"
//功能未实现的默认控制器成员变量
@interface DefaultViewController (){
    
}
@end
//功能未实现的默认控制器实现类
@implementation DefaultViewController
#pragma mark 启动入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //创建默认图片面板
    [self createDefaultImageView];
}
#pragma mark 默认画面
-(void)createDefaultImageView{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coming_soon.jpg"]];
    
    CGRect tempFrame = [self loadVisibleViewFrame];
    tempFrame.size.width *= 0.7;
    tempFrame.size.height *= 0.7;
    imageView.frame = [self loadVisibleViewFrame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = [self loadVisibleViewCenter];
    //imageView.backgroundColor = [UIColor redColor];
    [self.view addSubview:imageView];
    
}
#pragma mark 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
