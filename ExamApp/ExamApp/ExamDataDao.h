//
//  ExamDataDao.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import <Foundation/Foundation.h>
@class FMDatabase;
@class ExamData;
//考试数据数据库操作
@interface ExamDataDao : NSObject
//初始化。
-(instancetype)initWithDb:(FMDatabase *)db;
//统计全部的数据
-(NSInteger)total;
//根据索引加载指定的数据
-(ExamData *)loadDataAtIndex:(NSInteger)index;
//根据指定索引加载考试代码
-(NSString *)loadExamCodeAtIndex:(NSInteger)index;
//根据指定索引加载考试名称
-(NSString *)loadExamNameAtIndex:(NSInteger)index;
//同步数据。
-(void)syncWithData:(NSDictionary *)data;
@end
