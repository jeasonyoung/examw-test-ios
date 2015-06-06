//
//  FeedbackViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FeedbackViewController.h"

#import "FeedbackTableViewCell.h"

#define __kFeedbackViewController_title @"意见反馈"
#define __kFeedbackViewController_cellIdentifer @"cell"//
//反馈视图控制器成员变量
@interface FeedbackViewController ()<FeedbackTableViewCellDelegate,UIAlertViewDelegate>{
    UIAlertView *_alertView;
}
@end
//反馈视图控制器实现
@implementation FeedbackViewController

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
    self.title = __kFeedbackViewController_title;
}

#pragma mark UITableViewDataSource
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"创建行:%@...", indexPath);
    FeedbackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kFeedbackViewController_cellIdentifer];
    if(!cell){
        cell = [[FeedbackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:__kFeedbackViewController_cellIdentifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [FeedbackTableViewCell cellHeight];
}

#pragma mark FeedbackTableViewCellDelegate
-(void)feedBackCell:(FeedbackTableViewCell *)cell click:(UIButton *)sender body:(NSString *)body{
    NSLog(@"点击事件[%@][%@]..", cell, sender);
    _alertView = [[UIAlertView alloc] initWithTitle:@"致谢" message:@"您的意见就是我们进步的动力!我们将认真研究您的每一条建议,并运用于App中." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [_alertView show];
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //控制器跳转
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
