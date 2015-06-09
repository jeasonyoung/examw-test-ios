//
//  PaperViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//试卷控制器代理
@class PaperViewController;
@class PaperItemModel;
@protocol PaperViewControllerDelegate <NSObject>

@required
//加载数据源(PaperItemModel数组,异步线程调用)
-(NSArray *)dataSourceOfPaperView;
//加载试题答案(异步线程中调用)
-(NSString *)loadMyAnswerWithModel:(PaperItemModel *)itemModel;
//加载答题卡数据(异步线程中被调用)
-(void)loadAnswerCardDataWithSection:(NSArray **)sections andAllData:(NSDictionary **)dict;

@optional
//加载的当前试题题序(异步线程中调用)
-(NSUInteger)currentOrderOfPaperView;
//考试时长(分钟)
-(NSUInteger)timeOfPaperView;
//更新做题记录到SQL(异步线程中调用)
-(void)updateRecordAnswerWithModel:(PaperItemModel *)itemModel myAnswers:(NSString *)myAnswers useTimes:(NSUInteger)times;
//更新收藏记录(异步线程中被调用)
-(BOOL)updateFavoriteWithModel:(PaperItemModel *)itemModel;
//交卷处理(异步线程中被调用)
-(void)submitPaper:(void(^)(NSString* paperRecordId))resultController;
@end

//试卷控制器
@interface PaperViewController : UIViewController
//代理
@property(nonatomic,assign)id<PaperViewControllerDelegate> delegate;

//是否显示答案
@property(nonatomic,assign)BOOL displayAnswer;

//初始化
-(instancetype)initWithDisplayAnswer:(BOOL)display;

//加载到指定题序的试题
-(void)loadItemOrder:(NSUInteger)order;
@end
