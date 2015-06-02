//
//  PaperRecordService.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperRecordService.h"

#import "PaperItemModel.h"

#import "DaoHelpers.h"
#import "PaperUtils.h"
//试卷记录服务成员变量
@interface PaperRecordService (){
    FMDatabaseQueue *_dbQueue;
}
@end
//试卷记录服务实现
@implementation PaperRecordService

#pragma mark 重构初始化
-(instancetype)init{
    if(self = [super init]){
        DaoHelpers *dao = [[DaoHelpers alloc] init];
        if(dao){
            _dbQueue = [dao createDatabaseQueue];
            if(!_dbQueue){
                NSLog(@"创建数据库操作失败!");
            }
        }
    }
    return self;
}



@end
