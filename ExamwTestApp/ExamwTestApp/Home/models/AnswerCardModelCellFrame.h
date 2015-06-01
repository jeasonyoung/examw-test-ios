//
//  AnswerCardModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AnswerCardModel;
//答题卡试题数据模型CellFrame
@interface AnswerCardModelCellFrame : NSObject

//序号
@property(nonatomic,copy,readonly)NSString *order;
//序号字体
@property(nonatomic,readonly)UIFont *orderFont;
//序号Frame
@property(nonatomic,assign,readonly)CGRect orderFrame;

//背景色
@property(nonatomic,readonly)UIColor *orderBgColor;

//序号数据模型
@property(nonatomic,copy)AnswerCardModel *model;

+(CGSize)cellSize;

@end
