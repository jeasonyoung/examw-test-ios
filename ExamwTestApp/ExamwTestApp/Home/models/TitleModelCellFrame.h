//
//  TitleModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"

@class TitleModel;
//标题数据模型
@interface TitleModelCellFrame : NSObject<DataModelCellFrame>
//标题
@property(nonatomic,copy,readonly)NSString *title;
//标题字体
@property(nonatomic,strong,readonly)UIFont *titleFont;
//标题Frame
@property(nonatomic,assign,readonly)CGRect titleFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//数据模型
@property(nonatomic,copy)TitleModel *model;
@end
