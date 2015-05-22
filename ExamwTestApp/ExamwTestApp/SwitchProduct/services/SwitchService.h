//
//  CategoryService.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/18.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ExamModel;
//产品切换数据服务
@interface SwitchService : NSObject

//是否有考试分类数据
@property(nonatomic,assign,readonly)BOOL hasCategories;

//加载考试分类数据
-(NSArray *)loadAllCategories;

//从网络加载数据
-(void)loadCategoriesFromNetWorks:(void(^)(NSString *))complete withProgress:(void(^)(NSUInteger))progressPercentage;

//加载考试分类下的考试集合
-(NSArray *)loadExamsWithCategoryId:(NSString *)categoryId outCategoryName:(NSString **)categoryName;

//根据考试名称模糊查询搜索考试
-(void)findSearchExamsWithName:(NSString *)searchName resultBlock:(void(^)(ExamModel *))result;

//根据考试ID加载产品集合
-(NSArray *)loadProductsWithExamId:(NSString *)examId outExamName:(NSString **)examName;

//同步下载数据
-(void)syncDownload:(void(^)(BOOL,NSString *))handler;
@end
