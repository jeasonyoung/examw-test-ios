//
//  Category.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/15.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//考试分类数据模型
@interface CategoryModel : NSObject<JSONSerialize>
//分类ID
@property(nonatomic,copy)NSString *Id;
//分类代码
@property(nonatomic,copy)NSNumber *code;
//分类名称
@property(nonatomic,copy)NSString *name;
//分类EN简称
@property(nonatomic,copy)NSString *abbr;
//考试集合
@property(nonatomic,copy)NSArray *exams;
//从本地文件中加载
+(NSArray *)categoriesFromLocal;
//保存到本地文件中
+(BOOL)saveLocalWithArrays:(NSArray *)categories;
//将JSON数组转化为考试分类数据模型数组
+(NSArray *)categoriesFromJSON:(NSArray *)arrays;
@end
