//
//  PaperDetailsViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaperInfoModel;
//试卷明细视图控制器
@interface PaperDetailsViewController : UITableViewController

//初始化
-(instancetype)initWithPaperInfo:(PaperInfoModel *)model;

@end
