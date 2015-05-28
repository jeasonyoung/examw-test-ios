//
//  PaperItemOptModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"

@class PaperItemOptModel;
//试题选项数据模型
@interface PaperItemOptModelCellFrame : NSObject<DataModelCellFrame>
//选项icon
@property(nonatomic,readonly)UIImage *icon;
//选项iconFrame
@property(nonatomic,assign,readonly)CGRect iconFrame;
//选项内容
@property(nonatomic,copy,readonly)NSAttributedString *content;
//选项内容Frame
@property(nonatomic,assign,readonly)CGRect contentFrame;
//是否被选中
@property(nonatomic,assign,readonly)BOOL isSelected;
//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;
//数据模型
@property(nonatomic,copy)PaperItemOptModel *model;
@end
