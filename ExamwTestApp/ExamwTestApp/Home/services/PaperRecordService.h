//
//  PaperRecordService.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PaperItemModel;
//试卷记录服务
@interface PaperRecordService : NSObject

//加载试题记录中的答案
-(NSString *)loadRecordAnswersWithPaperRecordId:(NSString *)recordId itemModel:(PaperItemModel *)model;

//添加试题记录
-(void)addRecordWithPaperRecordId:(NSString *)recordId itemModel:(PaperItemModel *)model myAnswers:(NSString *)answers;

//收藏/取消收藏(收藏返回true,取消返回false)
-(BOOL)updateFavoriteWithPaperRecordId:(NSString *)recordId itemModel:(PaperItemModel *)model;

@end