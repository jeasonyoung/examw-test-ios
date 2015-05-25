//
//  PaperInfoModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"
@class PaperInfoModel;
//试卷信息数据模型的CellFrame
@interface PaperInfoModelCellFrame : NSObject<DataModelCellFrame>
//试卷标题
@property(nonatomic,copy,readonly)NSString *title;
//试卷标题字体
@property(nonatomic,readonly)UIFont *titleFont;
//试卷标题Frame
@property(nonatomic,assign,readonly)CGRect titleFrame;

//所属科目
@property(nonatomic,copy,readonly)NSString *subject;
//所属科目字体
@property(nonatomic,readonly)UIFont *subjectFont;
//所属科目Frame
@property(nonatomic,assign,readonly)CGRect subjectFrame;

//试题总数
@property(nonatomic,copy,readonly)NSString *total;
//试题总数字体
@property(nonatomic,readonly)UIFont *totalFont;
//试题总数Frame
@property(nonatomic,assign,readonly)CGRect totalFrame;

//创建时间
@property(nonatomic,copy,readonly)NSString *createTime;
//创建时间字体
@property(nonatomic,readonly)UIFont *createTimeFont;
//创建时间Frame
@property(nonatomic,assign,readonly)CGRect createTimeFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//数据模型
@property(nonatomic,copy)PaperInfoModel *model;
@end
