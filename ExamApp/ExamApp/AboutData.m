//
//  AboutData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AboutData.h"
//关于应用数据
@implementation AboutData
#pragma mark 从字典中加载数据
+(instancetype)aboutWithDict:(NSDictionary *)dict{
    if(dict == nil || dict.count == 0)return nil;
    AboutData *data = [[AboutData alloc] init];
    for(NSString *key in dict.allKeys){
        [data setValue:[dict objectForKey:key] forKey:key];
    }
    return data;
}
#pragma mark 从文件中加载数据
+(instancetype)loadAboutData{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about_panel" ofType:@"plist"]];
    return [AboutData aboutWithDict:dict];
}
@end