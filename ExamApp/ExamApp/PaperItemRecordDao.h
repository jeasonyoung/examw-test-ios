//
//  PaperItemRecordDao.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaperReview.h"
@class FMDatabase;
@class PaperItemRecord;
//做题记录数据操作
@interface PaperItemRecordDao : NSObject
//初始化
-(instancetype)initWithDb:(FMDatabase *)db;
//根据试题记录ID加载数据
-(PaperItemRecord *)loadRecordWithItemRecordCode:(NSString *)itemRecordCode;
//加载试题记录
-(PaperItemRecord *)loadRecordWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode;
//加载试题记录的答案
-(NSString *)loadAnswerWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode;
//根据试卷记录ID和试题ID加载数据
-(PaperItemRecord *)loadLastRecordWithPaperRecordCode:(NSString *)paperRecordCode;
//判断试题记录是否存在
-(BOOL)exitRecordWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode;
//更新数据
-(BOOL)updateRecordWithItemRecord:(PaperItemRecord **)record;
//统计试卷记录下已做的试题数
-(NSNumber *)totalFinishItemsWithPaperRecordCode:(NSString *)paperRecordCode;
//统计试卷记录下的试题得分
-(NSNumber *)totalAllItemScoreWithPaperRecordCode:(NSString *)paperRecordCode;
//统计试卷记录下的试题用时
-(NSNumber *)totalAllUseTimesWithPaperRecordCode:(NSString *)paperRecordCode;
//统计做对的试题数量
-(NSNumber *)totalAllRightsWithPaperRecordCode:(NSString *)paperRecordCode;

//统计科目下的错题统计
-(NSInteger)totalWrongItemsWithSubjectCode:(NSString *)subjectCode;
//统计科目题型下的错题统计
-(NSInteger)totalWrongItemsWithSubjectCode:(NSString *)subjectCode AtItemType:(PaperItemType)itemType;
//加载错题
-(PaperItemRecord *)loadWrongItemWithSubjectCode:(NSString *)subjectCode AtOrder:(NSInteger)order;

//加载需要同步的数据集合
-(NSArray *)loadSyncRecords;
//更新同步标示
-(void)updateSyncFlagWithIgnoreRecords:(NSArray *)ignores;
//根据试卷记录ID删除试题记录
-(BOOL)deleteRecordWithPaperRecordCode:(NSString *)paperRecordCode;
@end
