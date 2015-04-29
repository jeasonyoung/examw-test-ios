//
//  FavoriteService.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PaperReview.h"

@class PaperItemFavorite;

//@class SubjectData;
//
//收藏服务
@interface FavoriteService : NSObject
//分页的每页数据量
@property(nonatomic,assign,readonly)NSUInteger rowsOfPage;
//加载考试数据
-(NSArray *)loadExams;
//分页加载收藏的考试科目集合
-(NSArray *)loadSubjectsWithExamCode:(NSString *)examCode Index:(NSUInteger)index;

////加载全部的考试数据统计。
//-(NSInteger)loadAllExamTotal;
////加载考试索引下的科目数据统计。
//-(NSInteger)loadSubjectTotalWithExamIndex:(NSInteger)index;
////加载指定索引的考试标题。
//-(NSString *)loadExamTitleWithIndex:(NSInteger)index;
////根据指定索引加载科目数据。
//-(void)loadWithExamWithIndex:(NSInteger)index
//               andSubjectRow:(NSInteger)row
//                       Block:(void(^)(SubjectData *subject,NSInteger favorites))block;
////根据科目ID获取科目名称
//-(NSString *)loadSubjectNameWithSubjectCode:(NSString *)subjectCode;
//加载科目下收藏的试题总数
-(NSUInteger)loadFavoritesWithSubjectCode:(NSString *)subjectCode;
//加载收藏答题卡
-(void)loadSheetWithSubjectCode:(NSString *)subjectCode
                    SheetsBlock:(void(^)(NSString *itemTypeName,NSArray *sheets))block;
//加载收藏数据
-(PaperItemFavorite *)loadFavoriteWithSubjectCode:(NSString *)subjectCode AtOrder:(NSInteger)order;
@end
