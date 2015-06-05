//
//  MyProductRegModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyProductRegModel.h"
#import "AppSettings.h"
//产品注册数据模型实现
@implementation MyProductRegModel

#pragma mark 初始化
-(instancetype)initWithAppSettings:(AppSettings *)setting{
    if((self = [super init]) && setting){
        _examName = setting.examName;
        _productId = setting.productId;
        _productName = setting.productName;
    }
    return self;
}

@end
