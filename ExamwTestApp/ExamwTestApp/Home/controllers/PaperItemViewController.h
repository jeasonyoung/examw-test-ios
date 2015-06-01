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
@protocol PaperItemViewControllerDelegate <NSObject>
@required
//
-(void)itemViewController:(PaperItemViewController *)controller singleClickOrder:(NSUInteger)order;
@end

@class PaperItemModel;
//试卷试题视图控制器
@interface PaperItemViewController : UITableViewController
//代理
@property(nonatomic,assign)id<PaperItemViewControllerDelegate> delegate;
//试卷记录ID
@property(nonatomic,copy)NSString *PaperRecordId;
//初始化
-(instancetype)initWithPaperItem:(PaperItemModel *)model andOrder:(NSUInteger)order andDisplayAnswer:(BOOL)display;
//收藏/取消收藏试题
-(void)favoriteItem:(void(^)(BOOL))result;

//开始做题
-(void)start;
@end