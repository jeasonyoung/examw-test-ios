//
//  ImitateSubjectService.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//@class SubjectData;
//模拟考场科目科目服务类
@interface ImitateSubjectService : NSObject
//分页的每页数据量
@property(nonatomic,assign,readonly)NSUInteger rowsOfPage;
//加载考试数据
-(NSArray *)loadExams;
//分页加载科目试题集合
-(NSArray *)loadSubjectsWithExamCode:(NSString *)examCode Index:(NSUInteger)index;
////加载全部的考试数据统计。
//-(NSInteger)loadAllExamTotal;
////加载考试索引下的科目数据统计。
//-(NSInteger)loadSubjectTotalWithExamIndex:(NSInteger)index;
////加载指定索引的考试标题。
//-(NSString *)loadExamTitleWithIndex:(NSInteger)index;
////根据制定索引加载科目数据。
//-(SubjectData *)loadSubjectWithExamIndex:(NSInteger)index andSubjectRow:(NSInteger)row;
@end