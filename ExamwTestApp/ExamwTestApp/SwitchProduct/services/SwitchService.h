//
//  CategoryService.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/18.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExamModel.h"
//产品切换数据服务
@interface SwitchService : NSObject
//页数据
@property(nonatomic,assign,readonly)NSUInteger pageOfRows;
//是否有考试分类数据
@property(nonatomic,assign,readonly)BOOL hasCategories;

//加载考试分类数据
-(NSArray *)loadAllCategories;

//从网络加载数据
-(void)loadCategoriesFromNetWorks:(void(^)())complete;

//加载考试分类下的考试集合
-(NSArray *)loadExamsWithCategoryId:(NSString *)categoryId outCategoryName:(NSString **)categoryName;

//根据考试名称模糊查询搜索考试
-(void)findSearchExamsWithName:(NSString *)searchName resultBlock:(void(^)(ExamModel *))result;
@end
