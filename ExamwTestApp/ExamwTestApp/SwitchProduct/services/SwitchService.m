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

#define __kSwitchService_pageRows _kAPP_DEFAULT_PAGEROWS//分页每页显示的数据
//产品切换数据服务成员变量
@interface SwitchService(){
    
}
@end
//产品切换数据服务实现
@implementation SwitchService
#pragma mark 加载本地存储数据
-(NSArray *)localData{
    static NSArray *arrays;
    if(!arrays){
        arrays = [CategoryModel categoriesFromLocal];
    }
    return arrays;
}
#pragma mark 分页加载考试分类数据
-(NSArray *)loadCategoriesWithPageIndex:(NSUInteger)pageIndex{
    //分页数据开始索引
    NSUInteger start = pageIndex * __kSwitchService_pageRows;
    //加载本地数据
    NSArray *localArrays = [self localData];
    //本地数据不存在，先从服务器上下载然后保存到本地
    if(!localArrays || localArrays.count == 0){
        //从网络加载数据
        ///TODO:
        
        if(localArrays && localArrays.count > 0){
            //开启线程保存数据到本地
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //保存数据到本地
                BOOL result = [CategoryModel saveLocalWithArrays:[localArrays copy]];
                //
                NSLog(@"保存考试分类数据到本地: %d", result);
            });
        }
    }
    //从本地数据中查询
    if(localArrays && localArrays.count > 0){
        if(start > localArrays.count - 1)return nil;
        NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:__kSwitchService_pageRows];
        for(NSUInteger index = start;((index < (start + __kSwitchService_pageRows)) && (index < localArrays.count - 1));index++){
            CategoryModel *categoryModel = [localArrays objectAtIndex:index];
            if(categoryModel){
                [arrays addObject:categoryModel];
            }
        }
        return arrays;
    }
    return nil;
}


@end
