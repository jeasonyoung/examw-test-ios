//
//  ExamBaseModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

//考试数据基础模型
@interface ExamBaseModel : NSObject
//考试ID
@property(nonatomic,copy)NSString *Id;
//考试代码
@property(nonatomic,copy)NSNumber *code;
//考试名称
@property(nonatomic,copy)NSString *name;
@end
