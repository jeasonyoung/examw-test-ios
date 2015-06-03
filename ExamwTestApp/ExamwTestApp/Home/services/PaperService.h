//
//  PaperService.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/24.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PaperModel;
@class PaperItemModel;
@class PaperRecordModel;
@class PaperResultModel;
//试卷服务接口
@interface PaperService : NSObject

//分页数据
@property(nonatomic,assign,readonly)NSUInteger pageOfRows;

//按试卷类型分页查找试卷信息数据
-(NSArray *)findPapersInfoWithPaperType:(NSUInteger)paperType andPageIndex:(NSUInteger)pageIndex;

//加载试卷
-(PaperModel *)loadPaperModelWithPaperId:(NSString *)paperId;

//加载最新的试卷记录
-(PaperRecordModel *)loadNewsRecordWithPaperId:(NSString *)paperId;

//按试卷记录ID加载试卷记录
-(PaperRecordModel *)loadRecordWithPaperRecordId:(NSString *)paperRecordId;

//新增试卷记录
-(void)addPaperRecord:(PaperRecordModel *)record;

//试题是否被收藏
-(BOOL)exitFavoriteWithModel:(PaperItemModel *)itemModel;

//试题是否在记录中存在(0-不存在，1-做对,2-做错)
-(NSUInteger)exitRecordWithPaperRecordId:(NSString *)paperRecordId itemModel:(PaperItemModel *)model;

//加载最新试题记录
-(NSString *)loadNewsItemIndexWithPaperRecordId:(NSString *)recordId;

//加载试题记录中的答案
-(NSString *)loadRecordAnswersWithPaperRecordId:(NSString *)recordId itemModel:(PaperItemModel *)model;

//添加试题记录
-(void)addRecordWithPaperRecordId:(NSString *)recordId itemModel:(PaperItemModel *)model myAnswers:(NSString *)answers useTimes:(NSUInteger)useTimes;

//收藏/取消收藏(收藏返回true,取消返回false)
-(BOOL)updateFavoriteWithPaperId:(NSString *)paperId itemModel:(PaperItemModel *)model;

//收藏/取消收藏(收藏返回true,取消返回false)
-(BOOL)updateFavoriteWithSubjectCode:(NSString *)subjectCode itemModel:(PaperItemModel *)model;

//交卷处理
-(void)submitWithPaperRecordId:(NSString *)paperRecordId;

//加载考试结果数据
-(PaperResultModel *)loadPaperResultWithPaperRecordId:(NSString *)paperRecordId;

//加载错题记录
-(NSArray *)totalErrorRecordsWithExamCode:(NSString *)examCode;

//加载收藏记录
-(NSArray *)totalFavoriteRecordsWithExamCode:(NSString *)examCode;

//根据科目加载收藏集合
-(NSArray *)loadFavoritesWithSubjectCode:(NSString *)subjectCode;

//根据科目加载错题集合
-(NSArray *)loadErrorsWithSubjectCode:(NSString *)subjectCode;

//根据考试加载试卷记录
-(NSArray *)totalPaperRecordsWithExamCode:(NSString *)examCode;
@end
