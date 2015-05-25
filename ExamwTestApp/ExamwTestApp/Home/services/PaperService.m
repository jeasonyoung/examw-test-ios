//
//  PaperService.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/24.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperService.h"
#import "AppConstants.h"

#import "DaoHelpers.h"
#import "PaperInfoModel.h"

#define __kPaperService_pageOfRows _kAPP_DEFAULT_PAGEROWS//分页
//试卷服务接口成员变量
@interface PaperService (){
    DaoHelpers *_daoHelpers;
}
@end
//试卷服务接口实现
@implementation PaperService

#pragma mark 重构初始化
-(instancetype)init{
    if(self = [super init]){
        _daoHelpers = [[DaoHelpers alloc] init];
        _pageOfRows = __kPaperService_pageOfRows;
    }
    return self;
}


#pragma mark 按试卷类型分页查找试卷信息数据
-(NSArray *)findPapersInfoWithPaperType:(NSUInteger)paperType andPageIndex:(NSUInteger)pageIndex{
    NSLog(@"按试卷类型[%d]分页[%d]查找试卷数据...", (int)paperType, (int)pageIndex);
    //创建数据操作队列
    FMDatabaseQueue *dbQueue = [_daoHelpers createDatabaseQueue];
    if(!dbQueue){
        NSLog(@"创建数据操作失败!");
        return nil;
    }
    static NSString *querySubjectNameSql = @"SELECT name FROM tbl_subjects WHERE code = ? limit 0,1";
    //拼接SQL
    NSMutableString *query_sql = [NSMutableString string];
    [query_sql appendString:@" SELECT id, title, total, createTime, subjectCode FROM tbl_papers "];
    [query_sql appendFormat:@" WHERE type = ? order by createTime desc limit %d,%d;",
     (int)(pageIndex * __kPaperService_pageOfRows), (int)__kPaperService_pageOfRows];
    
    __block NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:__kPaperService_pageOfRows];
    //查询数据
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSLog(@"exec-sql:%@", query_sql);
        FMResultSet *rs = [db executeQuery:query_sql, [NSNumber numberWithInteger:paperType]];
        while ([rs next]) {
            //科目
            NSString *subjectCode = [rs stringForColumn:@"subjectCode"], *subjectName = @"";
            if(subjectCode && subjectCode.length > 0){
                subjectName = [db stringForQuery:querySubjectNameSql, subjectCode];
            }
            //创建试卷信息模型
            PaperInfoModel *model = [[PaperInfoModel alloc] init];
            model.Id = [rs stringForColumn:@"id"];
            model.name = [rs stringForColumn:@"title"];
            model.total = [rs intForColumn:@"total"];
            model.subject = subjectName;
            model.createTime = [rs stringForColumn:@"createTime"];
            //添加到集合
            [arrays addObject:model];
        }
        [rs close];
    }];
    //返回数据集合
    return (arrays && arrays.count > 0) ? [arrays copy] : nil;
}

@end
