//
//  TitleModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "TitleModel.h"

//标题数据模型实现
@implementation TitleModel

#pragma mark 初始化
-(instancetype)initWithTitle:(NSString *)title{
    if(self = [super init]){
        _title = title;
    }
    return self;
}

@end
