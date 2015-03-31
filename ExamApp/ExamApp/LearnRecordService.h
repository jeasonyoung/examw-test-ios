//
//  LearnRecordService.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaperReview.h"
@class PaperData;
@class PaperRecord;
//学习记录服务
@interface LearnRecordService : NSObject
//加载全部的数据统计
-(NSInteger)loadAllTotal;
//按行加载试卷记录数据
-(void)loadRecordAtRow:(NSInteger)row Data:(void(^)(NSString *paperTypeName,NSString *paperTitle,PaperRecord *record))block;
//根据试卷ID加载试卷数据
-(PaperReview *)loadPaperReviewWithPaperCode:(NSString *)paperCode;
//删除数据
-(void)deleteWithPaperRecordCode:(NSString *)paperRecordCode;
@end
