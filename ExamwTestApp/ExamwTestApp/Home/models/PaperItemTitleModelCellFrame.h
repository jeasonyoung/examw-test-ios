//
//  PaperItemTitleModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"

//试题标题数据模型CellFrame
@class PaperItemTitleModel;
@interface PaperItemTitleModelCellFrame : NSObject<DataModelCellFrame>
//标题
@property(nonatomic,copy,readonly)NSAttributedString *title;
//标题Frame
@property(nonatomic,assign,readonly)CGRect titleFrame;
//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;
//设置数据模型
@property(nonatomic,copy)PaperItemTitleModel *model;
@end
