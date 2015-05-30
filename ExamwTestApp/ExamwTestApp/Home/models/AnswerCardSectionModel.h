//
//  AnswerCardSectionModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

//答题卡分组数据模型
@interface AnswerCardSectionModel : NSObject
//结构名称
@property(nonatomic,copy,readonly)NSString *title;
//结构描述
@property(nonatomic,copy,readonly)NSString *desc;

//初始化
-(instancetype)initWithTitle:(NSString *)title desc:(NSString *)desc;

@end
