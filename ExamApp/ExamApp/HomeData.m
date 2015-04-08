//
//  HomeData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "HomeData.h"
#import "NSString+Date.h"
//#import "AppConstant.h"

//#define __kHomeData_dateFormate @"yyyy-MM-dd"

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
//#pragma mark 加载考试日期
//static NSDate *exam_date = nil;
//+(NSDate *)loadExamDate{
//    if(exam_date) return exam_date;
//    //初始化数据持久
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSData *data = [defaults dataForKey:_kAppClientExamDate_key];
//    if(data && data.length > 0){
//        NSString *strValue = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        if(strValue && strValue.length > 0){
//            exam_date = [strValue toDateWithFormat:__kHomeData_dateFormate];
//            return exam_date;
//        }
//    }
//    if(_kAppClientExamDate && _kAppClientExamDate.length > 0){
//        exam_date = [_kAppClientExamDate toDateWithFormat:__kHomeData_dateFormate];
//        return exam_date;
//    }
//    return nil;
//}
//#pragma mark 更新考试日期
//+(void)updateExamDate:(NSDate *)date{
//    if(date){
//        NSString *strValue = [NSString stringFromDate:date withDateFormat:__kHomeData_dateFormate];
//        if(strValue && strValue.length > 0){
//            NSData *data = [strValue dataUsingEncoding:NSUTF8StringEncoding];
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setObject:data forKey:_kAppClientExamDate_key];
//            //更新数据
//            [defaults synchronize];
//            //
//            exam_date = date;
//        }
//    }
//}
@end
