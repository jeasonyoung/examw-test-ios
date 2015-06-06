//
//  DownViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "DownViewController.h"

#define __kDownViewController_title @"下载试卷"//
//下载视图控制器成员变量
@interface DownViewController ()

@end
//下载视图控制器实现
@implementation DownViewController

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kDownViewController_title;
    
    // Do any additional setup after loading the view.
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
