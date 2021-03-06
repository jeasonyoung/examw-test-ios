//
//  ItemViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaperReview;
@class PaperRecord;
//试题考试视图控制器
@interface ItemViewController : UIViewController
//初始化
-(instancetype)initWithPaper:(PaperReview *)review
                   andRecord:(PaperRecord *)record
            andDisplayAnswer:(BOOL)displayAnswer;
//初始化
-(instancetype)initWithPaper:(PaperReview *)review
                       Order:(NSInteger)order
                   andRecord:(PaperRecord *)record
            andDisplayAnswer:(BOOL)displayAnswer;
//加载数据
-(void)loadDataAtOrder:(NSInteger)order
      andDisplayAnswer:(BOOL)displayAnswer;
@end