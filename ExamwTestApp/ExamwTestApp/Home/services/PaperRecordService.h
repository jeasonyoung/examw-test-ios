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
-(NSString *)loadRecordAnswersWithPaperRecordId:(NSString *)recordId itemId:(NSString *)itemId;

//添加试题记录
-(void)addRecordWithPaperRecordId:(NSString *)recordId itemModel:(PaperItemModel *)model myAnswers:(NSString *)answers;

@end
