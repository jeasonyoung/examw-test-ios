//
//  MoreMenuModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataModelCellFrame.h"

@class MoreMenuModel;
//更多菜单数据模型CellFrame
@interface MoreMenuModelCellFrame : NSObject<DataModelCellFrame>

//图标图片
@property(nonatomic,strong,readonly)UIImage *icon;
//图标图片Frame
@property(nonatomic,assign,readonly)CGRect iconFrame;

//标题
@property(nonatomic,copy,readonly)NSString *title;
//标题字体
@property(nonatomic,strong,readonly)UIFont *titleFont;
//标题Frame
@property(nonatomic,assign,readonly)CGRect titleFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//数据模型
@property(nonatomic,copy)MoreMenuModel *model;
@end
