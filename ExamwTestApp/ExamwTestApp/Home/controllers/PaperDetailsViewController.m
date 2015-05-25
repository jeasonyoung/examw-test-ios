//
//  PaperDetailsViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperDetailsViewController.h"

#import "PaperInfoModel.h"
#import "PaperModel.h"

#import "PaperService.h"


#define __kPaperDetailsViewController_title @"试卷详情"//
//试卷明细视图控制器成员变量
@interface PaperDetailsViewController (){
    //试卷信息数据模型
    PaperInfoModel *_infoModel;
    //数据源
    NSMutableArray *_dataSource;
}
@end

//试卷明细视图控制器实现
@implementation PaperDetailsViewController

#pragma mark 初始化
-(instancetype)initWithPaperInfo:(PaperInfoModel *)model{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        _infoModel = model;
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kPaperDetailsViewController_title;
    //初始化数据源
    _dataSource = [NSMutableArray arrayWithCapacity:4];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
