//
//  HomeData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "HomeData.h"
#import "NSString+Date.h"

//主页九宫格数据实现类
@implementation HomeData
#pragma mark 构造函数
+(instancetype)homeDataWithDict:(NSDictionary *)dict{
    if(dict == nil || dict.count == 0) return nil;
    HomeData *data = [[HomeData alloc] init];
    for(NSString *key in dict.allKeys){
        [data setValue:[dict objectForKey:key] forKey:key];
    }
    return data;
}
#pragma mark 从文件加载数据集合
+(NSArray *)loadHomeData{
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"home_panel" ofType:@"plist"]];
    if(array == nil || array.count == 0)return nil;
    NSMutableArray *list = [NSMutableArray array];
    for(int i = 0; i < array.count; i++){
        HomeData *data = [HomeData homeDataWithDict:[array objectAtIndex:i]];
        if(data != nil){
            [list addObject:data];
        }
    }
    return list;
}
@end
