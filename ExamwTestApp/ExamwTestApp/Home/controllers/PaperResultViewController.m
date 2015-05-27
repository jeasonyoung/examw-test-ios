//
//  PaperResultViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperResultViewController.h"

//试卷结果视图控制器成员变量
@interface PaperResultViewController (){
    NSString *_paperRecordId;
}
@end

//试卷结果视图控制器实现
@implementation PaperResultViewController

#pragma mark 初始化
-(instancetype)initWithPaperRecordId:(NSString *)recordId{
    if(self = [super init]){
        _paperRecordId = recordId;
    }
    return self;
}

#pragma mark 静态初始化
+(instancetype)resultControllerWithPaperRecordId:(NSString *)recordId{
    NSLog(@"试卷结果视图控制器...");
    return [[self alloc] initWithPaperRecordId:recordId];
}

#pragma mark UI入口
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
