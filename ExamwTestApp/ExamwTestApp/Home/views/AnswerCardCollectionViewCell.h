//
//  AnswerCardCollectionViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnswerCardCollectionViewCell;
//答题卡集合Cell代理
@protocol AnswerCardCollectionViewCellDelegate <NSObject>
@required
//点击事件
-(void)answerCardCell:(AnswerCardCollectionViewCell *)cell clickOrder:(NSUInteger)order;
@end

@class AnswerCardModelCellFrame;
//答题卡集合Cell
@interface AnswerCardCollectionViewCell : UICollectionViewCell
//代理
@property(nonatomic,assign)id<AnswerCardCollectionViewCellDelegate> delegate;
//加载模型Frame
-(void)loadModelCellFrame:(AnswerCardModelCellFrame *)cellFrame;
@end
