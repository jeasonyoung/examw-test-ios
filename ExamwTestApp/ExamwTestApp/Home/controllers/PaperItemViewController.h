//
//  PaperItemViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//试卷试题视图控制器代理
@class PaperItemViewController;
@class PaperItemModel;
@protocol PaperItemViewControllerDelegate <NSObject>
@required
//单选点击处理
-(void)itemViewController:(PaperItemViewController *)controller singleClickOrder:(NSUInteger)order;
//加载当前试题答案记录
-(NSString *)itemViewController:(PaperItemViewController *)controller loadMyAnswerWithModel:(PaperItemModel *)itemModel;
//更新做题记录
-(void)updateRecordAnswerWithModel:(PaperItemModel *)itemModel myAnswers:(NSString *)myAnswers useTimes:(NSUInteger)times;
//更新收藏记录
-(BOOL)updateFavoriteWithModel:(PaperItemModel *)itemModel;
@end

@class PaperItemModel;
//试卷试题视图控制器
@interface PaperItemViewController : UITableViewController
//代理
@property(nonatomic,assign)id<PaperItemViewControllerDelegate> delegate;

//初始化
-(instancetype)initWithPaperItem:(PaperItemModel *)model andOrder:(NSUInteger)order andDisplayAnswer:(BOOL)display;
//收藏/取消收藏试题
-(void)favoriteItem:(void(^)(BOOL))result;
//开始做题
-(void)start;
@end