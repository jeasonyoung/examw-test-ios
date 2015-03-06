//
//  AnswersheetViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaperReview;
//答题卡视图控制器
@interface AnswersheetViewController : UIViewController
//初始化
-(instancetype)initWithPaperReview:(PaperReview *)review PaperRecordCode:(NSString *)recordCode;
@end