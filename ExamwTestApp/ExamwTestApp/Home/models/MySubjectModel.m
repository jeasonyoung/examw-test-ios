//
//  MyModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MySubjectModel.h"

//我的列表数据模型实现
@implementation MySubjectModel
#pragma mark 初始化
-(instancetype)initWithIcon:(NSString *)icon{
    if(self = [super init]){
        _iconName = icon;
    }
    return self;
}
@end
