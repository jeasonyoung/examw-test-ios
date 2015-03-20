//
//  ResultViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaperReview;
@class PaperRecord;
//答题情况试图控制器
@interface ResultViewController : UIViewController
//是否为答题卡
@property(nonatomic,assign)BOOL isAnswersheet;
//试题题序
@property(nonatomic,assign)NSInteger itemOrder;
//初始化
-(instancetype)initWithPaper:(PaperReview *)review andRecord:(PaperRecord *)record;
@end
