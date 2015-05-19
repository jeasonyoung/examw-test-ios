//
//  CategoryService.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/18.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SwitchService.h"
#import "CategoryModel.h"

#import "AppConstants.h"
#import "HttpUtils.h"

#import "JSONCallback.h"

#define __kSwitchService_pageRows _kAPP_DEFAULT_PAGEROWS//分页每页显示的数据
//产品切换数据服务成员变量
@interface SwitchService(){
    
}
@end
//产品切换数据服务实现
@implementation SwitchService
#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _pageOfRows = __kSwitchService_pageRows;
    }
    return self;
}

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
-(NSArray *)loadCategoriesWithPageIndex:(NSUInteger)pageIndex{
    NSLog(@"加载[%d]页考试分类数据...",pageIndex);
    //分页数据开始索引
    NSUInteger start = pageIndex * __kSwitchService_pageRows;
    //加载本地数据
    if(!localCategoriesCache){
        localCategoriesCache = [CategoryModel categoriesFromLocal];
    }
    //从本地数据中查询
    if(localCategoriesCache && localCategoriesCache.count > 0){
        if(start > localCategoriesCache.count - 1)return nil;
        NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:__kSwitchService_pageRows];
        for(NSUInteger index = start;((index < (start + __kSwitchService_pageRows)) && (index < localCategoriesCache.count - 1));index++){
            CategoryModel *categoryModel = [localCategoriesCache objectAtIndex:index];
            if(categoryModel){
                [arrays addObject:categoryModel];
            }
        }
        return arrays;
    }
    return nil;
}
#pragma mark 从网络下载数据
-(void)loadCategoriesFromNetWorks:(void (^)())complete{
    NSLog(@"从网络下载数据...");
    //从网络加载数据
    [HttpUtils checkNetWorkStatus:^(BOOL statusValue) {
        NSLog(@"检测网络状态:%d", statusValue);
        if(statusValue){
            [HttpUtils JSONDataWithUrl:_kAPP_API_CATEGORY_URL method:HttpUtilsMethodGET parameters:nil
                               success:^(NSDictionary *dict) {//进入主线程
                                   //开启后台线程处理
                                   dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                                       @try {
                                           NSLog(@"开启后台线程处理JSON转换");
                                           JSONCallback *callback = [JSONCallback callbackWithDict:dict];
                                           if(callback.success){
                                               NSArray *arrays = callback.data;
                                               if(!arrays || arrays.count == 0){
                                                   NSLog(@"反馈数据[%@]转换为数组失败！",callback.data);
                                                   return;
                                               }
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
                                               NSLog(@"下载数据失败:%@",callback.msg);
                                           }
                                       }
                                       @catch (NSException *exception) {
                                           NSLog(@"后台线程处理下载数据异常:%@", exception);
                                       }
                                       @finally{
                                           //处理完成
                                           complete();
                                       }
                                   });
                               } fail:^(NSString *err) {
                                   NSLog(@"下载数据失败:%@", err);
                               }];
        }
    }];
}
@end
