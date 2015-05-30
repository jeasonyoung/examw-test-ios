//
//  AnswerCardModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswerCardModel.h"

//答题卡试题数据模型实现
@implementation AnswerCardModel

#pragma mark 初始化
-(instancetype)initWithOrder:(NSUInteger)order status:(BOOL)status{
    if(self = [super init]){
        _order = order;
        _status = status;
    }
    return self;
}

@end
