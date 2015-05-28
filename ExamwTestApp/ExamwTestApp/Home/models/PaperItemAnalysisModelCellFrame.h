//
//  PaperItemAnalysisModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"

@class PaperItemAnalysisModel;
//试题答案解析数据模型CellFrame
@interface PaperItemAnalysisModelCellFrame : NSObject<DataModelCellFrame>
//参考答案
@property(nonatomic,copy,readonly)NSString *rightAnswers;
//参考答案字体
@property(nonatomic,readonly)UIFont *rightAnswersFont;
//参考答案Frame
@property(nonatomic,assign,readonly)CGRect rightAnswersFrame;

//我的答案
@property(nonatomic,copy,readonly)NSString *myAnswers;
//我的答案字体
@property(nonatomic,readonly)UIFont *myAnswersFont;
//我的答案背景色
@property(nonatomic,readonly)UIColor *myAnswersBgColor;
//我的答案Frame
@property(nonatomic,assign,readonly)CGRect myAnswersFrame;

//题目解析
@property(nonatomic,copy,readonly)NSAttributedString *analysis;
//题目解析Frame
@property(nonatomic,assign,readonly)CGRect analysisFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;
//数据模型
@property(nonatomic,copy)PaperItemAnalysisModel *model;
@end
