//
//  PaperTitleModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"

@class PaperTitleModel;
//试卷标题模型CellFrame
@interface PaperTitleModelCellFrame : NSObject<DataModelCellFrame>

//试卷标题
@property(nonatomic,copy,readonly)NSString *title;
//试卷标题字体
@property(nonatomic,readonly)UIFont *titleFont;
//试卷标题Frame
@property(nonatomic,assign,readonly)CGRect titleFrame;

//科目
@property(nonatomic,copy,readonly)NSString *subject;
//科目字体
@property(nonatomic,readonly)UIFont *subjectFont;
//科目Frame
@property(nonatomic,assign,readonly)CGRect subjectFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//
@property(nonatomic,copy)PaperTitleModel *model;
@end
