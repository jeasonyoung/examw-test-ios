//
//  PaperButtonModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperButtonModel.h"

//试卷按钮数据模型实现
@implementation PaperButtonModel

#pragma mark 初始化
-(instancetype)initWithPaperRecord:(PaperRecordModel *)recordModel{
    if(self = [super init]){
        _recordModel = recordModel;
    }
    return self;
}
@end
