//
//  PaperRecordService.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperRecordService.h"
#import <FMDB/FMDB.h>
#import "UserAccountData.h"

#import "PaperRecord.h"
#import "PaperRecordDao.h"
//试卷记录服务成员变量
@interface PaperRecordService (){
    FMDatabaseQueue *_dbQueue;
}
@end
//试卷记录服务实现
@implementation PaperRecordService
#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        NSError *err;
        NSString *dbPath = [[UserAccountData currentUser] loadDatabasePath:&err];
        if(!dbPath){
            NSLog(@"PaperRecordService加载数据文件路径时错误：%@",err);
        }else{
            _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        }
    }
    return self;
}
#pragma mark 内存回收
-(void)dealloc{
    if(_dbQueue){
        [_dbQueue close];
    }
}
@end
