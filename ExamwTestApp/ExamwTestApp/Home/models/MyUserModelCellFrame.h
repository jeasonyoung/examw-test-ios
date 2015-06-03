//
//  MyUserModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataModelCellFrame.h"

//用户信息数据模型CellFrame
@class UserAccount;
@interface MyUserModelCellFrame : NSObject<DataModelCellFrame>
//用户头像
@property(nonatomic,readonly)UIImage *img;
//用户头像Frame
@property(nonatomic,assign,readonly)CGRect imgFrame;

//标题
@property(nonatomic,copy,readonly)NSString *title;
//标题字体
@property(nonatomic,copy,readonly)UIFont *titleFont;
//标题Frame
@property(nonatomic,assign,readonly)CGRect titleFrame;

//注册码
@property(nonatomic,copy,readonly)NSString *regCode;
//注册码字体
@property(nonatomic,copy,readonly)UIFont *regCodeFont;
//注册码Frame
@property(nonatomic,assign,readonly)CGRect regCodeFrame;

//用户注册
@property(nonatomic,copy,readonly)NSString *userReg;
//用户注册字体
@property(nonatomic,copy,readonly)UIFont *userRegFont;
//用户注册Frame
@property(nonatomic,assign,readonly)CGRect userRegFrame;

//用户登录
@property(nonatomic,copy,readonly)NSString *userLogin;
//用户登录字体
@property(nonatomic,copy,readonly)UIFont *userLoginFont;
//用户登录Frame
@property(nonatomic,assign,readonly)CGRect userLoginFrame;

//Cell高度
@property(nonatomic,assign,readonly)CGFloat cellHeight;

//数据模型
@property(nonatomic,copy)UserAccount *model;
@end
