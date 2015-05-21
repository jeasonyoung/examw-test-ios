//
//  DaoHelpers.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

//DAO操作工具基础类
@interface DaoHelpers : NSObject

//数据库操作队列
@property(nonatomic,readonly)FMDatabaseQueue *dbQueue;

//静态初始化
+(instancetype)helpers;
@end
