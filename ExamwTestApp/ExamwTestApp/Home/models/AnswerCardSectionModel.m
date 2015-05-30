//
//  AnswerCardSectionModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswerCardSectionModel.h"

//答题卡分组数据模型
@implementation AnswerCardSectionModel

#pragma mark 初始化
-(instancetype)initWithTitle:(NSString *)title desc:(NSString *)desc{
    if(self = [super init]){
        _title = title;
        _desc = desc;
    }
    return self;
}

@end
