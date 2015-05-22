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

/**
 * 创建数据库操作对象.
 * @return FMDatabase
 */
-(FMDatabase *)createDatabase;

/**
 * 创建数据库操作队列.
 * @return FMDatabaseQueue
 */
-(FMDatabaseQueue *)createDatabaseQueue;

//静态初始化
+(instancetype)helpers;
@end
