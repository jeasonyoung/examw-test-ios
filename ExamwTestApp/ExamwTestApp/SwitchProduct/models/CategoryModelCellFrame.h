//
//  CategoryModelFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"

#import "CategoryModel.h"

//考试分类数据模型CellFrame
@interface CategoryModelCellFrame : NSObject<DataModelCellFrame>
//考试分类名称
@property(nonatomic,copy,readonly)NSString *categoryName;
//考试分类字体
@property(nonatomic,readonly)UIFont *categoryFont;
//考试分类Frame
@property(nonatomic,assign,readonly)CGRect categoryFrame;

//考试字体
@property(nonatomic,readonly)UIFont *examFont;
//考试1名称
@property(nonatomic,copy,readonly)NSString *exam1Name;
//考试1Frame
@property(nonatomic,assign,readonly)CGRect exam1Frame;
//考试2名称
@property(nonatomic,copy,readonly)NSString *exam2Name;
//考试2Frame
@property(nonatomic,assign,readonly)CGRect exam2Frame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;
//数据模型
@property(nonatomic,copy)CategoryModel *model;
@end
