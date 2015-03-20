//
//  FavoriteSubjectViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FavoriteSubjectViewController.h"

#define __kFavoriteSubjectViewController_title @"我的收藏"
//收藏科目列表成员变量
@interface FavoriteSubjectViewController (){
    
}
@end
//收藏科目列表实现
@implementation FavoriteSubjectViewController
#pragma mark UI加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //标题
    self.title = __kFavoriteSubjectViewController_title;
    // Do any additional setup after loading the view.
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
