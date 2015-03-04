//
//  ItemViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemViewController.h"
#import "PaperReview.h"
#import "PaperRecord.h"
//试题考试视图控制器成员变量
@interface ItemViewController (){
    PaperReview *_review;
    PaperRecord *_paperRecord;
}
@end
//试题考试视图控制器实现
@implementation ItemViewController
#pragma mark 初始化
-(instancetype)initWithPaper:(PaperReview *)review andRecord:(PaperRecord *)record{
    if(self = [super init]){
        _review = review;
        _paperRecord = record;
    }
    return  self;
}
#pragma 加载界面入口
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
