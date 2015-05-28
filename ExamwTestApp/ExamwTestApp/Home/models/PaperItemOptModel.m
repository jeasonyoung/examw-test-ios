//
//  PaperItemOptModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemOptModel.h"
#import "PaperItemModel.h"
//试题选项数据模型实现
@implementation PaperItemOptModel

#pragma mark 重载初始化
-(instancetype)initWithItemModel:(PaperItemModel *)itemModel{
    if((self = [super initWithItemModel:itemModel]) && itemModel){
        _rightAnswers = itemModel.itemAnswer;
    }
    return self;
}

@end
