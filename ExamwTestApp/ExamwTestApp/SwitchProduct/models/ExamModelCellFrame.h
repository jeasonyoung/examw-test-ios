//
//  ExamModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"
#import "ExamModel.h"

//考试CellFrame
@interface ExamModelCellFrame : NSObject<DataModelCellFrame>
//考试名称
@property(nonatomic,copy,readonly)NSString *name;
//考试名称字体
@property(nonatomic,readonly)UIFont *nameFont;
//考试名称Frame
@property(nonatomic,assign,readonly)CGRect nameFrame;
//Cell行高
@property(nonatomic,assign,readonly)CGFloat cellHeight;
//考试数据模型
@property(nonatomic,copy)ExamModel *model;
@end
