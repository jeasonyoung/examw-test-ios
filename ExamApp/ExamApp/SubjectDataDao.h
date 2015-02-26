//
//  SubjectDataDao.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
//科目数据操作类。
@interface SubjectDataDao : NSObject
//初始化
-(instancetype)initWithDb:(FMDatabase *)db;
//从数据库中加载全部数据
-(NSArray *)loadAllWithExamCode:(NSString *)code;
@end