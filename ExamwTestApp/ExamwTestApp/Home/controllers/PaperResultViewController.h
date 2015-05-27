//
//  PaperResultViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//试卷结果视图控制器
@interface PaperResultViewController : UIViewController

//初始化
-(instancetype)initWithPaperRecordId:(NSString *)recordId;

//静态初始化
+(instancetype)resultControllerWithPaperRecordId:(NSString *)recordId;

@end
