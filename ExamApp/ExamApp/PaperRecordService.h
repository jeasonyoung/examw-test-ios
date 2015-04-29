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
@class PaperItemFavorite;
@class PaperItemOrderIndexPath;
//试卷记录服务
@interface PaperRecordService : NSObject
//加载最新试卷记录
-(PaperRecord *)loadLastRecordWithPaperCode:(NSString *)paperCode;
//加载试卷记录
-(PaperRecord *)loadRecordWithPaperRecordCode:(NSString *)paperRecordCode;
//创建新的试卷记录
-(PaperRecord *)createNewRecordWithPaperCode:(NSString *)paperCode;
//更新试卷记录
-(BOOL)updatePaperRecord:(PaperRecord **)paperRecord;
//交卷
-(void)submitWithPaperRecord:(PaperRecord *)record;

//加载最新的做题记录
-(PaperItemRecord *)loadLastRecordWithPaperRecordCode:(NSString *)paperRecordCode;
//加载完成的试题数
-(NSNumber *)loadFinishItemsWithPaperRecordCode:(NSString *)paperRecordCode;
//加载做对的试题数
-(NSNumber *)loadRightItemsWithPaperRecordCode:(NSString *)paperRecordCode;
//加载试题记录
-(PaperItemRecord *)loadRecordWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode atIndex:(NSInteger)index;
//加载试题记录(如果不存在就创建新记录)
-(PaperItemRecord *)loadRecordAndNewWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode atIndex:(NSInteger)index;
//加载试题记录中的答案
-(NSString *)loadAnswerRecordWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode atIndex:(NSInteger)index;
//是否存在试题记录
-(BOOL)exitItemRecordWithPaperRecordCode:(NSString *)paperRecordCode ItemCode:(NSString *)itemCode atIndex:(NSInteger)index;
//提交试题记录
-(void)submitWithItemRecord:(PaperItemRecord *)itemRecord;

//检查试题收藏是否存在
-(BOOL)exitFavoriteWithPaperCode:(NSString *)code ItemCode:(NSString *)itemCode atIndex:(NSInteger)index;
//添加试题收藏
-(void)addFavoriteWithPaperCode:(NSString *)code Data:(PaperItemOrderIndexPath *)indexPath;
//删除试题收藏
-(void)removeFavoriteWithPaperCode:(NSString *)code ItemCode:(NSString *)itemCode atIndex:(NSInteger)index;
@end