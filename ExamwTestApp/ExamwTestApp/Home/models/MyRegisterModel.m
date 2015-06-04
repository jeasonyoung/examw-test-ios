//
//  MyRegisterModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyRegisterModel.h"
//注册用户数据模型实现
@implementation MyRegisterModel

#pragma mark 初始化
-(instancetype)initWithFieldname:(NSString *)fieldname placeholder:(NSString *)placeholder isEmail:(BOOL)isEmail{
    if(self = [super init]){
        _isRequired = YES;
        _fieldname = fieldname;
        _placeholder = placeholder;
        _isEmail = isEmail;
    }
    return self;
}

#pragma mark 初始化
-(instancetype)initWithFieldname:(NSString *)fieldname placeholder:(NSString *)placeholder{
    return [self initWithFieldname:fieldname placeholder:placeholder isEmail:NO];
}

@end
