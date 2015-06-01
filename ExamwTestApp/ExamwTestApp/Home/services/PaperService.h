//
//  PaperService.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/24.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PaperModel;
@class PaperItemModel;
@class PaperRecordModel;
@class PaperResultModel;
//试卷服务接口
@interface PaperService : NSObject

//分页数据
@property(nonatomic,assign,readonly)NSUInteger pageOfRows;

//按试卷类型分页查找试卷信息数据
-(NSArray *)findPapersInfoWithPaperType:(NSUInteger)paperType andPageIndex:(NSUInteger)pageIndex;

//加载试卷
-(PaperModel *)loadPaperModelWithPaperId:(NSString *)paperId;

//加载最新的试卷记录
-(PaperRecordModel *)loadNewsRecordWithPaperId:(NSString *)paperId;

//按试卷记录ID加载试卷记录
-(PaperRecordModel *)loadRecordWithPaperRecordId:(NSString *)paperRecordId;

//新增试卷记录
-(void)addPaperRecord:(PaperRecordModel *)record;

//试题是否被收藏
-(BOOL)exitFavoriteWithItemId:(NSString *)itemId;

//试题是否在记录中存在(0-不存在，1-做对,2-做错)
-(NSUInteger)exitRecordWithPaperRecordId:(NSString *)paperRecordId itemModel:(PaperItemModel *)model;

//加载最新试题记录
-(NSString *)loadNewsItemIndexWithPaperRecordId:(NSString *)recordId;

//交卷处理
-(void)submitWithPaperRecordId:(NSString *)paperRecordId;

//加载考试结果数据
-(PaperResultModel *)loadPaperResultWithPaperRecordId:(NSString *)paperRecordId;

//加载错题记录
-(NSArray *)totalErrorRecords;

//加载收藏记录
-(NSArray *)totalFavoriteRecords;
@end
