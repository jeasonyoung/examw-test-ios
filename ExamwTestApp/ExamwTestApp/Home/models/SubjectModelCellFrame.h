//
//  SubjectModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/16.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"
#import "SubjectModel.h"

//考试科目数据模型CellFrame
@interface SubjectModelCellFrame : NSObject<DataModelCellFrame>

//科目名称
@property(nonatomic,copy, readonly)NSString *name;
//科目名称字体
@property(nonatomic,strong,readonly)UIFont *nameFont;
//科目名称Frame
@property(nonatomic,assign,readonly)CGRect nameFrame;

//试卷统计
@property(nonatomic,copy,readonly)NSString *total;
//试卷统计字体
@property(nonatomic,strong,readonly)UIFont *totalFont;
//试卷统计Frame
@property(nonatomic,assign,readonly)CGRect totalFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//数据模型
@property(nonatomic,copy)SubjectModel *model;
@end
