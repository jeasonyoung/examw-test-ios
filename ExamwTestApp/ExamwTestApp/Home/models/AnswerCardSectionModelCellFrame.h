//
//  AnswerCardSectionModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AnswerCardSectionModel;
//答题卡分组数据模型CellFrame
@interface AnswerCardSectionModelCellFrame : NSObject

//标题
@property(nonatomic,copy,readonly)NSString *title;
//标题字体
@property(nonatomic,readonly)UIFont *titleFont;
//标题Frame
@property(nonatomic,assign,readonly)CGRect titleFrame;

//描述
@property(nonatomic,copy,readonly)NSString *desc;
//描述字体
@property(nonatomic,readonly)UIFont *descFont;
//描述Frame
@property(nonatomic,assign,readonly)CGRect descFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGSize cellSize;

//数据模型
@property(nonatomic,copy)AnswerCardSectionModel *model;
@end
