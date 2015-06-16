//
//  SubjectModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/16.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

//考试科目数据模型
@interface SubjectModel : NSObject

//科目代码
@property(nonatomic,copy)NSString *code;
//科目名称
@property(nonatomic,copy)NSString *name;
//试卷统计
@property(nonatomic,assign)NSUInteger total;

@end
