//
//  PaperRecordDao.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
@class PaperRecord;
//试卷记录数据操作
@interface PaperRecordDao : NSObject
//初始化
-(instancetype)initWithDb:(FMDatabase *)db;
//统计做题记录数据
-(NSInteger)total;
//根据记录ID加载数据
-(PaperRecord *)loadPaperRecord:(NSString *)recordCode;
//加载最新的试卷记录
-(PaperRecord *)loadLastPaperRecord:(NSString *)paperCode;
//按行加载数据
-(PaperRecord *)loadDataAtRow:(NSInteger)row;
//更新数据
-(BOOL)updateRecord:(PaperRecord **)record;
//删除数据
-(BOOL)deleteRecordWithCode:(NSString *)code;
//加载需同步的数据集合
-(NSArray*)loadSyncRecords;
//更新同步标示
-(void)updateSyncFlagWithIgnoreRecords:(NSArray *)ignores;
@end
