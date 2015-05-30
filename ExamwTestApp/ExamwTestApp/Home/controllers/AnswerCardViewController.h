//
//  AnswerCardViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//答题卡试图控制器代理
@class AnswerCardViewController;
@protocol AnswerCardViewControllerDelegate<NSObject>
//题序选中事件处理
-(void)answerCardViewController:(AnswerCardViewController *)controller clickOrder:(NSUInteger)order;
@end

//答题卡试图控制器
@interface AnswerCardViewController : UICollectionViewController
//代理处理
@property(nonatomic,assign)id<AnswerCardViewControllerDelegate> delegate;

//初始化
-(instancetype)initWithPaperId:(NSString *)paperId andPaperRecordId:(NSString *)recordId;
@end