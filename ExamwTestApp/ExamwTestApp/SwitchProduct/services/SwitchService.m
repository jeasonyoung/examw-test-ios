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
#import "HttpUtils.h"

#import "JSONCallback.h"

#import "DownloadDao.h"
//产品切换数据服务成员变量
@interface SwitchService(){
    
}
@end
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
    NSLog(@"从网络下载数据...");
    //下载进度
//    void (^downloadProgress)(long long,long long) = ^(long long totalBytesRead, long long totalBytesExpectedToRead){
//        if(progressPercentage){//进度百分比
//            progressPercentage((int)((totalBytesRead * 100)/totalBytesExpectedToRead));
//        }
//    };
    //下载成功处理
    void (^successHandler)(NSDictionary *) = ^(NSDictionary *dict){//主线程
        //开启后台线程处理
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            NSString *msg = @"";
            @try {
                NSLog(@"开启后台线程处理JSON转换");
                JSONCallback *callback = [JSONCallback callbackWithDict:dict];
                if(callback.success){
                    NSArray *arrays = callback.data;
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
            }
            @catch (NSException *exception) {
                msg = [NSString stringWithFormat:@"发生异常:%@",exception];
                NSLog(@"后台线程处理下载数据异常:%@", exception);
            }
            @finally{
                //处理完成
                complete(msg);
            }
        });
    };
    //从网络加载数据
    [HttpUtils checkNetWorkStatus:^(BOOL statusValue) {
        NSLog(@"检测网络状态:%d", statusValue);
        if(statusValue){
            [HttpUtils JSONDataWithUrl:_kAPP_API_CATEGORY_URL method:HttpUtilsMethodGET parameters:nil
                              progress:nil
                               success:successHandler
                                  fail:^(NSString *err) {
                                      //开启后台线程处理
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                                          NSLog(@"服务器错误:%@", err);
                                          complete([NSString stringWithFormat:@"服务器错误:%@",err]);
                                      });
                                  }];
        }
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
-(NSArray *)loadProductsWithExamId:(NSString *)examId outExamName:(NSString *__autoreleasing *)examName{
    NSLog(@"根据考试ID[%@]加载产品集合...", examId);
    if(examId && examId.length > 0 && [self hasCategories]){
        for (CategoryModel *category in localCategoriesCache){
            if(!category || !category.exams || category.exams.count == 0) continue;
            for(ExamModel *exam in category.exams){
                if(exam && exam.Id && [examId isEqualToString:exam.Id]){
                    NSLog(@"加载考试分类:%@", exam.name);
                    if(examName){
                        *examName = exam.name;
                    }
                    return [exam.products copy];
                }
            }
        }
    }
    return nil;
}

#pragma mark 同步下载数据
-(void)syncDownload:(void (^)(BOOL, NSString *))handler{
    DownloadDao *dao = [[DownloadDao alloc] init];
    [dao downloadWithIgnoreCode:YES andResult:handler];
}
@end
