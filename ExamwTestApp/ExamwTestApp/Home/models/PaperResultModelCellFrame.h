//
//  PaperResultModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"
//试卷结果模型Cell Frame
@class PaperResultModel;
@interface PaperResultModelCellFrame : NSObject<DataModelCellFrame>

//标题
@property(nonatomic,copy,readonly)NSString *title;
//标题字体
@property(nonatomic,readonly)UIFont *titleFont;
//标题Frame
@property(nonatomic,assign,readonly)CGRect titleFrame;

//内容
@property(nonatomic,copy,readonly)NSString *content;
//内容字体
@property(nonatomic,readonly)UIFont *contentFont;
//内容字体颜色
@property(nonatomic,readonly)UIColor *contentFontColor;
//内容Frame
@property(nonatomic,assign,readonly)CGRect contentFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//加载分数
-(void)loadScoreWithModel:(PaperResultModel *)model;
//加载总题数
-(void)loadTotalWithModel:(PaperResultModel *)model;
//加载做对题数
-(void)loadRightsWithModel:(PaperResultModel *)model;
//加载做错题数
-(void)loadErrorsWithModel:(PaperResultModel *)model;
//加载未做题数
-(void)loadNotsWithModel:(PaperResultModel *)model;
//加载用时
-(void)loadUseTimeWithModel:(PaperResultModel *)model;
//加载起止时间
-(void)loadTimeWithModel:(PaperResultModel *)model;
@end
