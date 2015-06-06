//
//  FeedbackTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//意见反馈Cell代理
@class FeedbackTableViewCell;
@protocol FeedbackTableViewCellDelegate <NSObject>

//按钮点击事件处理
-(void)feedBackCell:(FeedbackTableViewCell *)cell click:(UIButton *)sender body:(NSString *)body;

@end
//意见反馈Cell
@interface FeedbackTableViewCell : UITableViewCell
//代理
@property(nonatomic,assign)id<FeedbackTableViewCellDelegate> delegate;
//行高
+(CGFloat)cellHeight;

@end
