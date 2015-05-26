//
//  PaperDetailsModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"

@class PaperDetailsModel;
//试卷明细数据模型CellFrame
@interface PaperDetailsModelCellFrame : NSObject<DataModelCellFrame>

//描述
@property(nonatomic,copy,readonly)NSString *desc;
//描述字体
@property(nonatomic,readonly)UIFont *descFont;
//描述Frame
@property(nonatomic,assign,readonly)CGRect descFrame;

//试卷来源
@property(nonatomic,copy,readonly)NSString *source;
//试卷来源字体
@property(nonatomic,readonly)UIFont *sourceFont;
//试卷来源Frame
@property(nonatomic,assign,readonly)CGRect sourceFrame;

//所属地区
@property(nonatomic,copy,readonly)NSString *area;
//所属地区字体
@property(nonatomic,readonly)UIFont *areaFont;
//所属地区Frame
@property(nonatomic,assign,readonly)CGRect areaFrame;

//试卷类型
@property(nonatomic,copy,readonly)NSString *type;
//试卷类型字体
@property(nonatomic,readonly)UIFont *typeFont;
//试卷类型Frame
@property(nonatomic,assign,readonly)CGRect typeFrame;

//考试时长
@property(nonatomic,copy,readonly)NSString *time;
//考试时长字体
@property(nonatomic,readonly)UIFont *timeFont;
//考试时长Frame
@property(nonatomic,assign,readonly)CGRect timeFrame;

//使用年份
@property(nonatomic,copy,readonly)NSString *year;
//使用年份字体
@property(nonatomic,readonly)UIFont *yearFont;
//使用年份frame
@property(nonatomic,assign,readonly)CGRect yearFrame;

//试题数
@property(nonatomic,copy,readonly)NSString *total;
//试题数字体
@property(nonatomic,readonly)UIFont *totalFont;
//试题数Frame
@property(nonatomic,assign,readonly)CGRect totalFrame;

//试卷总分
@property(nonatomic,copy,readonly)NSString *score;
//试卷总分字体
@property(nonatomic,readonly)UIFont *scoreFont;
//试卷总分Frame
@property(nonatomic,assign,readonly)CGRect scoreFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//数据模型
@property(nonatomic,copy)PaperDetailsModel *model;
@end
