//
//  AppClientPush.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppClient.h"
//客户端数据推送
@interface AppClientPush : AppClient

//注册码
@property(nonatomic,copy,readonly)NSString *code;
//用户ID
@property(nonatomic,copy,readonly)NSString *userId;

//上传记录数据
@property(nonatomic,copy)NSArray *records;

//初始化上传记录
-(instancetype)initWithRecords:(NSArray *)records;

@end
