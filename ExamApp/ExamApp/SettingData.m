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
    data.key = [dict objectForKey:@"key"];
    data.title = [dict objectForKey:@"title"];
    data.type = [dict objectForKey:@"type"];
    data.data = [dict objectForKey:@"data"];
    return data;
}
#pragma mark 加载对象集合
+(NSArray *)loadSettingData{
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"settings_panel" ofType:@"plist"]];
    if(array == nil || array.count == 0) return nil;
    NSMutableArray *list = [NSMutableArray array];
    for(int i = 0; i < array.count; i++){
        SettingData *data = [SettingData settingDataWithDict:[array objectAtIndex:i]];
        if(data != nil){
            [list addObject:data];
        }
    }
    return list;
}
@end
