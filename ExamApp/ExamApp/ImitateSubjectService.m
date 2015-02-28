//
//  ImitateSubjectService.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "ImitateSubjectService.h"
#import <FMDB/FMDB.h>
#import "UserAccountData.h"
#import "ExamData.h"
#import "ExamDataDao.h"
#import "SubjectData.h"
#import "SubjectDataDao.h"
//模拟考场科目科目服务类成员变量
@interface ImitateSubjectService(){
    NSArray *_examArrays;
    NSMutableDictionary *_dictExamTitles,*_dictSubjects;
    FMDatabaseQueue *_dbQueue;
}
@end
//模拟考场科目科目服务类实现
@implementation ImitateSubjectService
#pragma mark 重载构造函数。
-(instancetype)init{
    if(self = [super init]){
        NSError *err;
        NSString *dbPath = [[UserAccountData currentUser] loadDatabasePath:&err];
        if(!dbPath){
            NSLog(@"加载数据库文件路径时错误:%@",err);
        }else{
            _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        }
    }
    return self;
}
#pragma mark 加载全部的考试数据统计。
-(NSInteger)loadAllExamTotal{
    if(!_examArrays && _dbQueue){//惰性加载考试数据缓存
        //线程安全的数据操作队列
        [_dbQueue inDatabase:^(FMDatabase *db) {
            //初始化考试数据操作对象
            ExamDataDao *examDao = [[ExamDataDao alloc] initWithDb:db];
            //加载全部的考试数据数组
            _examArrays = [examDao loadAll];
        }];
    }
    return _examArrays ? _examArrays.count : 0;
}
#pragma mark 加载考试索引下的科目数据统计。
-(NSInteger)loadSubjectTotalWithExamIndex:(NSInteger)index{
    //排除索引<0
    if(index < 0) return 0;
    if(!_dictSubjects){//惰性加载数据缓存。
        _dictSubjects = [NSMutableDictionary dictionary];
    }
    //从缓存中加载数据
    __block NSArray *subjectArrays = [_dictSubjects objectForKey:[NSNumber numberWithInteger:index]];
    if(!subjectArrays && _examArrays && index < _examArrays.count){//缓存中没有对应数据
        ExamData *exam = [_examArrays objectAtIndex:index];
        if(exam && _dbQueue){//查询数据库
            [_dbQueue inDatabase:^(FMDatabase *db) {
                //初始化科目数据操作对象
                SubjectDataDao *subjectDao = [[SubjectDataDao alloc] initWithDb:db];
                //加载考试下的科目数据
                subjectArrays = [subjectDao loadAllWithExamCode:exam.code];
                //添加到缓存
                if(subjectArrays){
                    [_dictSubjects setObject:subjectArrays forKey:[NSNumber numberWithInteger:index]];
                }
            }];
        }
    }
    return subjectArrays ? subjectArrays.count : 0;
}
#pragma mark 加载指定索引的考试标题。
-(NSString *)loadExamTitleWithIndex:(NSInteger)index{
    //排除索引 < 0
    if(index < 0) return nil;
    if(!_dictExamTitles){//惰性加载考试标题缓存
        _dictExamTitles = [NSMutableDictionary dictionary];
    }
    NSString *title = [_dictExamTitles objectForKey:[NSNumber numberWithInteger:index]];
    if(!title){
        if(!_examArrays){//考试数据缓存不存在时加载数据
            [self loadAllExamTotal];
        }
        //索引越界
        if(index > _examArrays.count) return nil;
        //加载考试数据
        ExamData *exam = [_examArrays objectAtIndex:index];
        if(exam){//考试数据存在
            //构建考试标题
            title = exam.name;
            //添加到缓存
            [_dictExamTitles setObject:title forKey:[NSNumber numberWithInteger:index]];
        }
    }
    return title;
}
#pragma mark 根据制定索引加载科目数据。
-(SubjectData *)loadSubjectWithExamIndex:(NSInteger)index andSubjectRow:(NSInteger)row{
    //排除索引小于0
    if(index < 0 || row < 0) return nil;
    if(!_dictSubjects){//科目缓存不存在时加载数据
        [self loadSubjectTotalWithExamIndex:index];
    }
    //从缓存中加载数据
    NSArray *subjectArray = [_dictSubjects objectForKey:[NSNumber numberWithInteger:index]];
    if(subjectArray && row < subjectArray.count){
        return [subjectArray objectAtIndex:row];
    }
    return nil;
}
#pragma mark 内存回收
-(void)dealloc{
    if(_dbQueue){
        [_dbQueue close];
    }
}
@end