//
//  MyRegisterModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//注册用户数据模型
@interface MyRegisterModel : NSObject
//字段名称
@property(nonatomic,copy)NSString *fieldname;
//占位名称
@property(nonatomic,copy)NSString *placeholder;
//是否为必填
@property(nonatomic,assign)BOOL isRequired;
//是否验证为邮件
@property(nonatomic,assign)BOOL isEmail;

//初始化
-(instancetype)initWithFieldname:(NSString *)fieldname placeholder:(NSString *)placeholder;
//初始化
-(instancetype)initWithFieldname:(NSString *)fieldname placeholder:(NSString *)placeholder isEmail:(BOOL)isEmail;
@end
