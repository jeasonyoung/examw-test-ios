//
//  PaperRecordService.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PaperRecord;
@class PaperItemRecord;
//试卷记录服务
@interface PaperRecordService : NSObject
//加载最新试卷记录
-(PaperRecord *)loadLastRecordWithPaperCode:(NSString *)paperCode;
//创建新的试卷记录
-(PaperRecord *)createNewRecordWithPaperCode:(NSString *)paperCode;
//更新试卷记录
-(BOOL)updatePaperRecord:(PaperRecord **)paperRecord;
//交卷
-(void)subjectWithPaperRecord:(PaperRecord *)record;

//加载最新的做题记录
-(PaperItemRecord *)loadLastRecordWithPaperRecordCode:(NSString *)paperRecordCode;
//加载试题记录
-(PaperItemRecord *)loadRecordWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode atIndex:(NSInteger)index;
//是否存在试题记录
-(BOOL)exitItemRecordWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode atIndex:(NSInteger)index;
//提交试题记录
-(void)subjectWithItemRecord:(PaperItemRecord *)itemRecord;
@end