//
//  PaperResultViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PaperViewController.h"

//试卷结果视图控制器
@interface PaperResultViewController : UITableViewController
//设置代理
@property(nonatomic,assign)id<PaperViewControllerDelegate> paperViewControllerDelegate;
//初始化
-(instancetype)initWithPaperRecordId:(NSString *)recordId;
@end
