//
//  ExamModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/18.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//考试数据模型
@interface ExamModel : NSObject
//考试ID
@property(nonatomic,copy)NSString *Id;
//考试代码
@property(nonatomic,copy)NSString *code;
//考试名称
@property(nonatomic,copy)NSString *name;
//考试EN简称
@property(nonatomic,copy)NSString *abbr;
//产品数据集合
@property(nonatomic,copy)NSArray *products;

//初始化考试
-(instancetype)initWithDict:(NSDictionary *)dict;
//序列化考试数据
-(NSDictionary *)serialize;
@end
