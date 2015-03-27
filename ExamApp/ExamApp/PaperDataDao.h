//
//  PaperDataDao.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaperReview.h"
@class FMDatabase;
@class FMDatabaseQueue;
@class PaperReview;
@class PaperData;
//试卷数据操作
@interface PaperDataDao : NSObject
//初始化
-(instancetype)initWithDb:(FMDatabase *)db;
//加载最新的数据同步时间
-(NSString *)loadLastSyncTime;
//加载试卷数据(无试卷内容)
-(PaperData *)loadPaperWithCode:(NSString *)code;
//根据试卷ID加载试卷内容
-(PaperReview *)loadPaperContentWithCode:(NSString *)code;
//根据试题ID加载试题所属科目代码
-(NSString *)loadSubjectCodeWithPaperCode:(NSString *)code;
//根据科目ID和试卷类型加载试卷数据集合
-(NSArray *)loadPapersWithSubjectCode:(NSString *)subjectCode PaperType:(PaperType)type;
//同步数据
-(void)syncWithData:(NSArray *)data;
@end