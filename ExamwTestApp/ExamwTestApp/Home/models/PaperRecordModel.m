//
//  PaperRecordModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperRecordModel.h"

//试卷做题记录数据模型实现
@implementation PaperRecordModel

#pragma mark 初始化
-(instancetype)initWithPaperId:(NSString *)paperId{
    if(self = [super init]){
        _Id = [[NSUUID UUID] UUIDString];
        _paperId = paperId;
    }
    return self;
}

@end
