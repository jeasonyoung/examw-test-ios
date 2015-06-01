//
//  PaperSegmentModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataModelCellFrame.h"

//试卷分段数据模型CellFrame
@class PaperSegmentModel;
@interface PaperSegmentModelCellFrame : NSObject<DataModelCellFrame>
//科目名称
@property(nonatomic,copy,readonly)NSString *subject;
//科目字体
@property(nonatomic,readonly)UIFont *subjectFont;
//科目Frame
@property(nonatomic,assign,readonly)CGRect subjectFrame;

//统计
@property(nonatomic,copy,readonly)NSString *total;
//统计字体
@property(nonatomic,readonly)UIFont *totalFont;
//统计Frame
@property(nonatomic,assign,readonly)CGRect totalFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//设置数据模型
@property(nonatomic,copy)PaperSegmentModel *model;
@end
