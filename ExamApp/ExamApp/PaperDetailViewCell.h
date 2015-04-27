//
//  PaperDetailCellTableViewCell.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaperDetailModelFrame;

//试卷明细Cell事件委托
@protocol PaperDetailViewCellDelegate <NSObject>
@required
//按钮点击事件
-(void)detailViewCell:(UITableViewCell *)cell didButtonClick:(UIButton *)sender;
@end

//试卷明细Cell
@interface PaperDetailViewCell : UITableViewCell
//事件委托
@property(nonatomic,assign)id<PaperDetailViewCellDelegate> delegate;
//初始化
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
//加载模型Frame
-(void)loadModelFrame:(PaperDetailModelFrame *)modelFrame;
@end

//试卷明细标题Cell
@interface PaperDetailTitleViewCell : PaperDetailViewCell
@end

#define __kPaperDetailViewCell_btnTypeStart 1//开始考试
#define __kPaperDetailViewCell_btnTypeContinue 2//继续考试
#define __kPaperDetailViewCell_btnTypeView 3//查看成绩
#define __kPaperDetailViewCell_btnTypeReview 4//重新开始
//试卷明细按钮Cell
@interface PaperDetailBtnsViewCell : PaperDetailViewCell
@end

//试卷明细描述Cell
@interface PaperDetailDescViewCell : PaperDetailViewCell
@end