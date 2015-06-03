//
//  MyModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataModelCellFrame.h"

@class MySubjectModel;
//我的列表数据模型CellFrame
@interface MySubjectModelCellFrame : NSObject<DataModelCellFrame>

//图标
@property(nonatomic,readonly)UIImage *icon;
//图标Frame
@property(nonatomic,assign,readonly)CGRect iconFrame;

//科目
@property(nonatomic,copy,readonly)NSString *subject;
//科目字体
@property(nonatomic,readonly)UIFont *subjectFont;
//科目Frame
@property(nonatomic,assign,readonly)CGRect subjectFrame;

//科目统计
@property(nonatomic,copy,readonly)NSString *total;
//科目统计字体
@property(nonatomic,readonly)UIFont *totalFont;
//科目统计Frame
@property(nonatomic,assign,readonly)CGRect totalFrame;

//数据模型
@property(nonatomic,copy)MySubjectModel *model;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;
@end
