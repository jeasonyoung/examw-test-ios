//
//  PaperButtonModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"

@class PaperButtonModel;
//试卷按钮数据模型
@interface PaperButtonModelCellFrame : NSObject<DataModelCellFrame>

//按钮字体
@property(nonatomic,readonly)UIFont *btnFont;

//按钮1名称
@property(nonatomic,copy,readonly)NSString *btn1Title;
//按钮1Frame
@property(nonatomic,readonly)CGRect btn1Frame;

//按钮2名称
@property(nonatomic,copy,readonly)NSString *btn2Title;
//按钮2Frame
@property(nonatomic,readonly)CGRect btn2Frame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//设置数据模型
@property(nonatomic,copy)PaperButtonModel *model;
@end
