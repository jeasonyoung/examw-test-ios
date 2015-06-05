//
//  MyProductRegModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DataModelCellFrame.h"

@class MyProductRegModel;
//产品注册数据模型Frame
@interface MyProductRegModelCellFrame : NSObject<DataModelCellFrame>

//考试名称
@property(nonatomic,copy,readonly)NSString *examName;
//考试名称字体
@property(nonatomic,readonly)UIFont *examNameFont;
//考试名称Frame
@property(nonatomic,assign,readonly)CGRect examNameFrame;

//产品名称
@property(nonatomic,copy,readonly)NSString *productName;
//产品名称字体
@property(nonatomic,readonly)UIFont *productNameFont;
//产品名称Frame
@property(nonatomic,assign,readonly)CGRect productNameFrame;

//产品注册码占位字符
@property(nonatomic,copy,readonly)NSString *productRegCodePlaceholder;
//产品注册码
@property(nonatomic,copy,readonly)NSString *productRegCode;
//产品注册码字体
@property(nonatomic,readonly)UIFont *productRegCodeFont;
//产品注册码Frame
@property(nonatomic,assign,readonly)CGRect productRegCodeFrame;

//产品注册按钮Frame
@property(nonatomic,assign,readonly)CGRect btnRegisterFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//数据模型
@property(nonatomic,copy)MyProductRegModel *model;
@end
