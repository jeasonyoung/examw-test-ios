//
//  MyProductRegModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AppSettings;
//产品注册数据模型
@interface MyProductRegModel : NSObject
//所属考试名称
@property(nonatomic,copy,readonly)NSString *examName;
//考试产品ID
@property(nonatomic,copy,readonly)NSString *productId;
//考试产品名称
@property(nonatomic,copy,readonly)NSString *productName;
//产品注册码
@property(nonatomic,copy)NSString *productRegCode;
//初始化
-(instancetype)initWithAppSettings:(AppSettings *)setting;
@end
