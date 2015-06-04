//
//  MyUserRegisterModelCellFrame.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataModelCellFrame.h"

@class MyRegisterModel;
//注册用户数据模型Frame
@interface MyRegisterModelCellFrame : NSObject<DataModelCellFrame>

//占位名称
@property(nonatomic,copy,readonly)NSString *placeholder;
//是否为必填
@property(nonatomic,assign,readonly)BOOL isRequired;
//是否验证为邮件
@property(nonatomic,assign,readonly)BOOL isEmail;

//字体
@property(nonatomic,readonly)UIFont *font;
//frame
@property(nonatomic,assign,readonly)CGRect frame;
//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//数据模型
@property(nonatomic,copy)MyRegisterModel *model;

@end
