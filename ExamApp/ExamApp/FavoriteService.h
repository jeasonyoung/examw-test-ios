//
//  FavoriteService.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SubjectData;
//收藏服务
@interface FavoriteService : NSObject
//加载全部的考试数据统计。
-(NSInteger)loadAllExamTotal;
//加载考试索引下的科目数据统计。
-(NSInteger)loadSubjectTotalWithExamIndex:(NSInteger)index;
//加载指定索引的考试标题。
-(NSString *)loadExamTitleWithIndex:(NSInteger)index;
//根据指定索引加载科目数据。
-(void)loadWithExamWithIndex:(NSInteger)index
               andSubjectRow:(NSInteger)row
                       Block:(void(^)(SubjectData *subject,NSInteger favorites))block;
@end
