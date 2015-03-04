//
//  PaperItemRecordDao.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
@class PaperItemRecord;
//做题记录数据操作
@interface PaperItemRecordDao : NSObject
//初始化
-(instancetype)initWithDb:(FMDatabase *)db;
//根据试题记录ID加载数据
-(PaperItemRecord *)loadItemRecord:(NSString *)itemRecordCode;
//根据试卷记录ID和试题ID加载数据
-(PaperItemRecord *)loadLastItemRecordWithPaperRecordCode:(NSString *)paperRecordCode PaperItemCode:(NSString *)itemCode;
//更新数据
-(BOOL)updateRecord:(PaperItemRecord **)record;
//加载需要同步的数据集合
-(NSArray *)loadSyncRecords;
//更新同步标示
-(void)updateSyncFlagWithIgnoreRecords:(NSArray *)ignores;
@end
