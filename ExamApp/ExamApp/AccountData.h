//
//  AccountData.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//账号数据
@interface AccountData : NSObject
//软件版本值
@property(nonatomic,assign)float version;
//账号ID
@property(nonatomic,copy)NSString *accountId;
//账号
@property(nonatomic,copy)NSString *account;
//密码
@property(nonatomic,copy)NSString *password;
//注册码
@property(nonatomic,copy)NSString *registerCode;
//校验码
@property(nonatomic,copy,readonly)NSString *checkCode;
//当前用户
+(instancetype)currentUser;
//保存用户数据
-(void)save;
//验证数据合法性
-(BOOL)validation;
@end