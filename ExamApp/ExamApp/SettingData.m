//
//  SettingData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SettingData.h"
//设置数据实现类
@implementation SettingData
#pragma mark 初始化创建对象
+(instancetype)settingDataWithDict:(NSDictionary *)dict{
    if(dict == nil || dict.count == 0) return nil;
    SettingData *data = [[SettingData alloc] init];
    for(NSString *key in dict.allKeys){
        [data setValue:[dict objectForKey:key] forKey:key];
    }
    return data;
}
#pragma mark 加载对象集合
+(NSDictionary *)settingDataGroups{
    NSDictionary *sourceDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"settings_panel" ofType:@"plist"]];
    if(sourceDict == nil || sourceDict.count == 0) return nil;
    NSMutableDictionary *targetDict = [NSMutableDictionary dictionary];
    NSArray *keyArrays = sourceDict.allKeys;
    for(int i = 0; i < keyArrays.count; i++){
        NSString *key = [keyArrays objectAtIndex:i];
        NSArray *targets = [SettingData settingDatawithArray:[sourceDict objectForKey:key]];
        if(targets != nil){
            [targetDict setObject:targets forKey:key];
        }
    }
    return targetDict;
};
//
+(NSArray *)settingDatawithArray:(NSArray *)sources{
    if(sources == nil || sources.count == 0) return nil;
    NSMutableArray *targets = [NSMutableArray array];
    for(int i = 0; i < sources.count; i++){
        SettingData *data = [SettingData settingDataWithDict:[sources objectAtIndex:i]];
        if(data != nil){
            [targets addObject:data];
        }
    }
    return targets;
}

#pragma mark 按分组索引加载数据集合
+(NSArray *)settingDataWithGroups:(NSDictionary *)groups forGroup:(int)group{
    if(groups == nil || groups.count == 0 || group < 0) return nil;
    return [groups objectForKey:[NSString stringWithFormat:@"group-%d",group]];
}
@end
