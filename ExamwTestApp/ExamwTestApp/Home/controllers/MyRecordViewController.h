//
//  MyRecordViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MySubjectModel;
//试卷记录视图控制器
@interface MyRecordViewController : UITableViewController

//初始化
-(instancetype)initWithModel:(MySubjectModel *)model;

@end
