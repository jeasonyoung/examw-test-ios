//
//  PaperTitleModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperTitleModel.h"

//试卷标题模型实现
@implementation PaperTitleModel

#pragma mark 初始化
-(instancetype)initWithTitle:(NSString *)title andSubject:(NSString *)subject{
    if(self = [super init]){
        _title = title;
        _subject = subject;
    }
    return self;
}

@end