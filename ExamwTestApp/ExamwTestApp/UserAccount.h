//
//  UserAccount.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

//用户账号信息
@interface UserAccount : NSObject
//用户ID
@property(nonatomic,copy,readonly)NSString *userId;
//用户账号
@property(nonatomic,copy,readonly)NSString *username;
//注册码
@property(nonatomic,copy,readonly)NSString *regCode;

//初始化
-(instancetype)initWithUserId:(NSString *)userId withUsername:(NSString *)username;

//根据用户账号加载账号数据
+(instancetype)accountWithUsername:(NSString *)username;

//当前用户
+(instancetype)current;

//验证密码
-(BOOL)validateWithPassword:(NSString *)password;

//更新密码
-(void)updatePassword:(NSString *)password;

//更新注册码
-(void)updateRegCode:(NSString *)regCode;

//保存数据
-(BOOL)save;

//保存为当前用户
-(BOOL)saveForCurrent;

//清除账号信息
-(void)clean;
@end
