//
//  SubjectDataDao.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
@class SubjectData;
//科目数据操作类。
@interface SubjectDataDao : NSObject
//初始化
-(instancetype)initWithDb:(FMDatabase *)db;
//统计考试下的科目
-(NSInteger)totalWithExamCode:(NSString *)examCode;
//加载考试代码科目索引数据
-(SubjectData *)loadDataWithExamCode:(NSString *)examCode AtRow:(NSInteger)row;
//同步数据
-(void)syncWithExamCode:(NSString *)examCode Data:(NSArray *)data;
@end