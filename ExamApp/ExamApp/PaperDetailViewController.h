//
//  PaperDetailViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//试卷明细视图控制器
@interface PaperDetailViewController : UIViewController
//初始化
-(instancetype)initWithPaperCode:(NSString *)paperCode;
//初始化
-(instancetype)initWithPaperCode:(NSString *)paperCode paperRecordCode:(NSString *)paperRecordCode;
@end