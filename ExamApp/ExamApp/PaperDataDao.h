//
//  PaperDataDao.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
@class FMDatabaseQueue;
@class PaperReview;
typedef NS_ENUM(NSUInteger, PaperTypes){
    PaperTypesOfREAL = 0x01,
    PaperTypesOfSIMU = 0x02,
    PaperTypesOfFORECAS = 0x03,
    PaperTypesOfPRACTICE = 0x04,
    PaperTypesOfCHAPTER =0x05,
    PaperTypesOfDAILY = 0x06
};
//试卷数据操作
@interface PaperDataDao : NSObject
//初始化
-(instancetype)initWithDb:(FMDatabase *)db;
//加载最新的数据同步时间
-(NSString *)loadLastSyncTime;
//根据试卷ID加载试卷内容
-(PaperReview *)loadPaperContentWithCode:(NSString *)code;
//根据科目ID和试卷类型加载试卷数据集合
-(NSArray *)loadPapersWithSubjectCode:(NSString *)subjectCode PaperType:(PaperTypes)type;
//同步数据
-(void)syncWithData:(NSArray *)data;
@end