//
//  CategoryService.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/18.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SwitchService.h"
#import "CategoryModel.h"
#import "ExamModel.h"

#import "AppConstants.h"
#import "DigestHTTPJSONProvider.h"

#import "JSONCallback.h"

#import "DownloadDao.h"

//产品切换数据服务实现
@implementation SwitchService

//本地静态缓存
static NSArray *localCategoriesCache;

#pragma mark 是否存在本地数据
-(BOOL)hasCategories{
    //加载本地数据
    if(!localCategoriesCache || localCategoriesCache.count == 0){
        localCategoriesCache = [CategoryModel categoriesFromLocal];
    }
    return (localCategoriesCache && localCategoriesCache.count > 0);
}

#pragma mark 分页加载考试分类数据
-(NSArray *)loadAllCategories{
    NSLog(@"加载全部考试分类数据...");
    //加载本地数据
    if(!localCategoriesCache){
        localCategoriesCache = [CategoryModel categoriesFromLocal];
    }
    return localCategoriesCache;
}

#pragma mark 从网络下载数据
-(void)loadCategoriesFromNetWorks:(void (^)(NSString *))complete{
    DigestHTTPJSONProvider *provider = [DigestHTTPJSONProvider shareProvider];
    //检测网络状态
    [provider checkNetworkStatus:^(BOOL statusValue) {
        NSLog(@"检测网络状态:%d", statusValue);
        if(!statusValue){
            complete(@"请检查网络状态!");
            return;
        }
        NSLog(@"开始从网络下载数据...");
        //从网络加载数据
        [provider getDataWithUrl:_kAPP_API_CATEGORY_URL parameters:nil success:^(NSDictionary *result) {
            @try {
                NSString *msg = @"";
                JSONCallback *callback = [JSONCallback callbackWithDict:result];
                if(callback.success){
                    NSArray *arrays;
                    if(callback.data && [callback.data isKindOfClass:[NSArray class]]){
                        arrays = (NSArray *)callback.data;
                    }
                    if(arrays && arrays.count > 0){
                        //数据转换
                        NSArray *downloads = [CategoryModel categoriesFromJSON:arrays];
                        if(downloads && downloads.count > 0){
                            //缓存对象
                            localCategoriesCache = [downloads copy];
                            //保存数据到本地
                            BOOL result = [CategoryModel saveLocalWithArrays:[downloads copy]];
                            NSLog(@"保存考试分类数据到本地: %d", result);
                        }
                    }else{
                        msg = @"下载数据格式不正确!";
                        NSLog(@"反馈数据[%@]转换为数组失败！",callback.data);
                    }
                }else{
                    msg = [NSString stringWithFormat:@"下载数据失败:%@",callback.msg];
                    NSLog(@"%@",msg);
                }
                //完成数据下载
                if(complete){complete(msg);}
            }
            @catch (NSException *exception) {
                NSLog(@"发生解析异常:%@", exception);
                if(complete){ complete(@"解析异常,请稍后再试!");}
            }
        } fail:^(NSString *err) {
            NSLog(@"服务器错误:%@", err);
            if(complete){ complete(@"服务器忙,请稍后再试!");}
        }];
    }];
}

#pragma mark 加载考试分类下的考试集合
-(NSArray *)loadExamsWithCategoryId:(NSString *)categoryId outCategoryName:(NSString *__autoreleasing *)categoryName{
    NSLog(@"开始加载考试分类[%@]下的考试集合...",categoryId);
    if(categoryId && categoryId.length > 0 && [self hasCategories]){
        for(CategoryModel *category in localCategoriesCache){
            if(category && category.Id && [categoryId isEqualToString:category.Id]){
                NSLog(@"加载考试分类:%@", category.name);
                if(categoryName){
                    *categoryName = category.name;
                }
                return [category.exams copy];
            }
        }
    }
    return nil;
}

#pragma mark 根据考试名称模糊查询搜索考试
-(void)findSearchExamsWithName:(NSString *)searchName resultBlock:(void (^)(ExamModel *))result{
    NSLog(@"根据考试名称[%@]模糊查询搜索考试...",searchName);
    if(searchName && searchName.length > 0 && [self hasCategories]){
        for(CategoryModel *category in localCategoriesCache){
            if(!category || !category.exams || category.exams.count == 0)continue;
            //开启新线程查询
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for(ExamModel *exam in category.exams){
                    if(!exam || !exam.name) continue;
                    NSRange rang = [exam.name rangeOfString:searchName];
                    if(rang.location == NSNotFound) continue;
                    //
                    NSLog(@"线程搜索到考试:%@[%@]---",exam.name, NSStringFromRange(rang));
                    if(result){
                        result(exam);
                    }
                }
            });
        }
    }
}

#pragma mark 根据考试ID加载产品集合
-(NSArray *)loadProductsWithExamId:(NSString *)examId{
    NSLog(@"根据考试ID[%@]加载产品集合...", examId);
    if(examId && examId.length > 0 && [self hasCategories]){
        for (CategoryModel *category in localCategoriesCache){
            if(!category || !category.exams || category.exams.count == 0) continue;
            for(ExamModel *exam in category.exams){
                if(exam && exam.Id && [examId isEqualToString:exam.Id]){
                    NSLog(@"加载考试分类:%@", exam.name);
                    return [exam.products copy];
                }
            }
        }
    }
    return nil;
}

#pragma mark 同步下载数据
-(void)syncDownloadWithIgnoreRegCode:(BOOL)ignoreRegCode resultHandler:(void (^)(BOOL, NSString *))handler{
    DownloadDao *dao = [[DownloadDao alloc] init];
    [dao downloadWithIgnoreCode:ignoreRegCode andResult:handler];
}
@end
