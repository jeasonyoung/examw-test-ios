//
//  ProductRegisterModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppClient.h"
//应用产品注册数据模型(用于到服务器端验证)
@interface ProductRegisterModel : AppClient

//用户ID
@property(nonatomic,copy,readonly)NSString *userId;

//注册码
@property(nonatomic,copy)NSString *code;

//初始化
-(instancetype)initWithCode:(NSString *)code;

@end
