//
//  WrongItemRecordService.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SubjectData;
@class PaperItemRecord;
//错题记录服务
@interface WrongItemRecordService : NSObject
//加载考试数据统计
-(NSInteger)loadAllExamTotal;
//加载考试索引下的科目数据统计
-(NSInteger)loadSubjectTotalWithExamIndex:(NSInteger)index;
//加载指定索引下的考试标题
-(NSString *)loadExamTitleWithSection:(NSInteger)section;
//加载科目数据
-(void)loadSubjectWithExamAtSection:(NSInteger)section
                             andRow:(NSInteger)row
                               Data:(void(^)(SubjectData *subject,NSInteger wrongs))block;
//根据科目ID获取科目名称
-(NSString*)loadSubjectNameWithSubjectCode:(NSString *)subjectCode;
//加载错题答题卡
-(void)loadSheetWithSubjectCode:(NSString *)subjectCode
                    SheetsBlock:(void(^)(NSString *itemTypeName,NSArray *sheets))block;
//加载错题数据
-(PaperItemRecord *)loadWrongWithSubjectCode:(NSString *)subjectCode
                                     AtOrder:(NSInteger)order;
@end