//
//  AnswerCardViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//答题卡试图控制器数据代理
@protocol AnswerCardViewControllerDataSource <NSObject>
//加载答题卡数据
-(void)loadAnswerCardDataWithSection:(NSArray **)sections andAllData:(NSDictionary **)dict;
@end

//答题卡试图控制器
@interface AnswerCardViewController : UICollectionViewController
//答题卡数据源
@property(nonatomic,assign)id<AnswerCardViewControllerDataSource> answerCardDataSource;
@end