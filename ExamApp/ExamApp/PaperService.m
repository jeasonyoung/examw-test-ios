//
//  PaperService.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperService.h"
#import <FMDB/FMDatabaseQueue.h>
#import "UserAccountData.h"
#import "PaperData.h"
#import "PaperReview.h"
#import "PaperDataDao.h"

#import "PaperRecord.h"
#import "PaperRecordDao.h"
//试卷服务类成员变量
@interface PaperService (){
    NSMutableDictionary *_papersCache,*_papersContentCache;
    FMDatabaseQueue *_dbQueue;
}
@end
//试卷服务类实现
@implementation PaperService
#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        NSError *err;
        NSString *dbPath = [[UserAccountData currentUser] loadDatabasePath:&err];
        if(!dbPath){
            NSLog(@"加载数据文件路径时错误：%@",err);
        }else{
            _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        }
    }
    return self;
}
#pragma mark 加载指定科目类型的试卷统计
-(NSInteger)loadPapersTotalWithSubjectCode:(NSString *)subjectCode PaperTypeValue:(NSInteger)typeValue{
    if(!subjectCode || subjectCode.length == 0) return 0;
    //加载缓存键
    NSString *cacheKey = [self loadCacheKeyWithSubjectCode:subjectCode PaperTypeValue:typeValue];
    if(!_papersCache){
        _papersCache = [NSMutableDictionary dictionary];
    }
    __block NSArray *paperArrays = [_papersCache objectForKey:cacheKey];
    if(!paperArrays && _dbQueue){
        //数据库操作队列
        [_dbQueue inDatabase:^(FMDatabase *db) {
            //初始化数据操作对象
            PaperDataDao *dao = [[PaperDataDao alloc] initWithDb:db];
            //加载科目类型下试卷集合
            paperArrays = [dao loadPapersWithSubjectCode:subjectCode PaperType:typeValue];
            if(paperArrays){
                //存储缓存
                [_papersCache setObject:paperArrays forKey:cacheKey];
            }
        }];
    }
    return (paperArrays ? paperArrays.count : 0);
}
#pragma mark 加载指定科目类型和行的试卷数据
-(PaperData *)loadPaperWithSubjectCode:(NSString *)subjectCode PaperTypeValue:(NSInteger)typeValue Row:(NSInteger)row{
    if(!subjectCode || subjectCode.length == 0 || row < 0)return nil;
    NSString *cacheKey = [self loadCacheKeyWithSubjectCode:subjectCode PaperTypeValue:typeValue];
    if(!_papersCache){//缓存不存在
        [self loadPapersTotalWithSubjectCode:subjectCode PaperTypeValue:typeValue];
    }
    //从缓存中加载对象
    NSArray *paperArrays = [_papersCache objectForKey:cacheKey];
    if(paperArrays && row < paperArrays.count){
        return [paperArrays objectAtIndex:row];
    }
    return nil;
}
//加载缓存键名
-(NSString *)loadCacheKeyWithSubjectCode:(NSString *)subjectCode PaperTypeValue:(NSInteger)typeValue{
    return [NSString stringWithFormat:@"%@-%ld",subjectCode,(long)typeValue];
}
#pragma mark 根据试卷ID加载试卷内容对象
-(PaperReview *)loadPaperWithCode:(NSString *)code{
    if(!code || code.length == 0) return nil;
    if(!_papersContentCache){//惰性加载缓存对象
        _papersContentCache = [NSMutableDictionary dictionary];
    }
    __block PaperReview *paper = [_papersContentCache objectForKey:code];
    if(!paper && _dbQueue){
        //数据库操作队列
        [_dbQueue inDatabase:^(FMDatabase *db) {
            //初始化数据操作对象
            PaperDataDao *dao = [[PaperDataDao alloc] initWithDb:db];
            //加载试卷对象
            paper = [dao loadPaperContentWithCode:code];
            if(paper){
                //添加到缓存
                [_papersContentCache setObject:paper forKey:code];
            }
        }];
    }
    return paper;
}
#pragma mark 根据试卷ID加载试卷记录
-(PaperRecord *)loadRecordWithPaperCode:(NSString *)paperCode{
    if(!_dbQueue || !paperCode || paperCode.length == 0) return nil;
    __block PaperRecord *record;
    [_dbQueue inDatabase:^(FMDatabase *db) {
        PaperRecordDao *dao = [[PaperRecordDao alloc] initWithDb:db];
        if(dao){
            record = [dao loadLastPaperRecord:paperCode];
        }
    }];
    return record;
}
#pragma mark 内存回收
-(void)dealloc{
    if(_dbQueue){
        [_dbQueue close];
    }
}
@end
