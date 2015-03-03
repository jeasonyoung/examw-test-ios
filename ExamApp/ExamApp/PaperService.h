//
//  PaperService.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PaperData;
@class PaperReview;
//试卷服务类
@interface PaperService : NSObject
//加载指定科目类型的试卷统计
-(NSInteger)loadPapersTotalWithSubjectCode:(NSString *)subjectCode PaperTypeValue:(NSInteger)typeValue;
//加载指定科目类型和行的试卷数据
-(PaperData *)loadPaperWithSubjectCode:(NSString *)subjectCode PaperTypeValue:(NSInteger)typeValue Row:(NSInteger)row;
//根据试卷ID加载试卷内容
-(PaperReview *)loadPaperWithCode:(NSString *)code;
@end