//
//  AppRegisterCode.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/18.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppClient.h"
//应用注册码
@interface AppRegisterCode : AppClient
//用户ID。
@property(nonatomic,copy) NSString *userId;
//应用注册码。
@property(nonatomic,copy) NSString *code;
//初始化注册码。
-(instancetype)initWithCode:(NSString *)code;
@end
