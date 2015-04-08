//
//  AppClientSettings.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//应用程序设置
@interface AppClientSettings : NSObject
//客户端标示(用于考试网用户登陆验证)
@property(nonatomic,copy,readonly)NSString *appClientID;
//客户端名称
@property(nonatomic,copy,readonly)NSString *appClientName;
//客户端版本
@property(nonatomic,assign,readonly)float appClientVersion;
//客户端类型代码
@property(nonatomic,assign,readonly)NSInteger appClientTypeCode;
//客户端频道(用于考试网用户登录验证)
@property(nonatomic,copy,readonly)NSString *appClientChannel;
//考试日期
@property(nonatomic,copy,readonly)NSDate *appClientExamDate;
//考试产品ID
@property(nonatomic,copy,readonly)NSString *appClientProductID;
//考试产品名称
@property(nonatomic,copy,readonly)NSString *appClientProductName;

//接口认证用户名
@property(nonatomic,copy,readonly)NSString *digestUsername;
//接口认证密码
@property(nonatomic,copy,readonly)NSString *digestPassword;

//同步产品数据URL
@property(nonatomic,copy,readonly)NSString *syncProductsUrl;
//注册提交URL
@property(nonatomic,copy,readonly)NSString *registerPostUrl;
//登录提交URL
@property(nonatomic,copy,readonly)NSString *loginPostUrl;
//注册码验证URL
@property(nonatomic,copy,readonly)NSString *appRegCodeValidUrl;
//同步产品下考试科目URL
@property(nonatomic,copy,readonly)NSString *syncExamSubjecstUrl;
//同步产品下试卷数据URL
@property(nonatomic,copy,readonly)NSString *syncPapersUrl;

//首页URL
@property(nonatomic,copy,readonly)NSString *homeUrl;
//考试指南地址
@property(nonatomic,copy,readonly)NSString *guideUrl;
//论坛地址
@property(nonatomic,copy,readonly)NSString *bbsUrl;
//客户端设置实例
+(instancetype)clientSettings;
//更新考试日期
-(void)updateWithExamDate:(NSDate *)examDate;
//更新产品ID和名称
-(void)updateWithProductID:(NSString *)productId andProductName:(NSString *)productName;
@end
