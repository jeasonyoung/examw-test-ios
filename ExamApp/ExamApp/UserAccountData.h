//
//  AccountData.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//账号数据
@interface UserAccountData : NSObject
//软件版本值
@property(nonatomic,assign)float version;
//账号ID
@property(nonatomic,copy)NSString *accountId;
//账号
@property(nonatomic,copy)NSString *account;
//用户姓名
@property(nonatomic,copy)NSString *name;
//密码
@property(nonatomic,copy)NSString *password;
//注册码
@property(nonatomic,copy)NSString *registerCode;
//校验码(校验原始数据的完整性)
@property(nonatomic,copy,readonly)NSString *checkCode;
//验证码(校验数据存储的完整性)
@property(nonatomic,copy,readonly)NSString *verifyCode;
//根据账号加载用户信息
+(instancetype)userWithAcount:(NSString *)account;
//当前用户
+(instancetype)currentUser;
//保存用户数据
-(void)save;
//保存为当前用户
-(void)saveForCurrent;
//验证数据合法性
-(BOOL)validation;
//清除账号数据
-(void)clean;
@end