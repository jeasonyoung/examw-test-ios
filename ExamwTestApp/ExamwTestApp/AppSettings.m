//
//  AppSettings.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppSettings.h"

#define __kAppSettings_defaults @"AppSettings"//用户默认配置键名
#define __kAppSettings_keys_examId @"examId"//考试Id键名
#define __kAppSettings_keys_examCode @"examCode"//考试代码键名
#define __kAppSettings_keys_examName @"examName"//考试名称键名
#define __kAppSettings_keys_productId @"productId"//产品ID键名
#define __kAppSettings_keys_productName @"productName"//产品名称键名
//应用全局设置实现
@implementation AppSettings
#pragma mark 从本地用户默认配置中加载设置
+(instancetype)settingsDefaults{
    NSLog(@"加载appSettings配置数据...");
    AppSettings *settings = [[self alloc]init];
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:__kAppSettings_defaults];
    if(data && data.length > 0){
        //JSON处理
        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        if(err){
            NSLog(@"应用全局设置JSON反序列化配置错误: %@",err);
        }else{
            [settings loadSettingValues:dict];
        }
    }
    return settings;
}
//加载设置的值
-(void)loadSettingValues:(NSDictionary *)dict{
    if(!dict || dict.count == 0)return;
    NSArray *keys = dict.allKeys;
    if(keys.count == 0)return;
    
    //考试ID
    if([keys containsObject:__kAppSettings_keys_examId]){
        id value = [dict objectForKey:__kAppSettings_keys_examId];
        _examId = (value == [NSNull null] ? @"" : value);
    }
    //考试代码
    if([keys containsObject:__kAppSettings_keys_examCode]){
        id value = [dict objectForKey:__kAppSettings_keys_examCode];
        _examCode = (value == [NSNull null] ? @0 : value);
    }
    //考试名称
    if([keys containsObject:__kAppSettings_keys_examName]){
        id value = [dict objectForKey:__kAppSettings_keys_examName];
        _examName = (value == [NSNull null] ? @"" : value);
    }
    
    //产品ID
    if([keys containsObject:__kAppSettings_keys_productId]){
        id value = [dict objectForKey:__kAppSettings_keys_productId];
        _productId = (value == [NSNull null] ? @"" : value);
    }
    //产品名称
    if([keys containsObject:__kAppSettings_keys_productName]){
        id value = [dict objectForKey:__kAppSettings_keys_productName];
        _productName = (value == [NSNull null] ? @"" : value);
    }
}

#pragma mark 设置考试
-(void)setExamWithId:(NSString *)examId andCode:(NSNumber *)examCode andName:(NSString *)examName{
    _examId = examId;
    _examCode = examCode;
    _examName = examName;
}

#pragma mark 设置产品
-(void)setProductWithId:(NSString *)productId andName:(NSString *)productName{
    _productId = productId;
    _productName  = productName;
}
#pragma mark 校验是否有效
-(BOOL)verification{
    if(!_examCode){
        NSLog(@"配置缺少=>考试代码D!");
        return NO;
    }
    if(!_examName || _examName.length == 0){
        NSLog(@"配置缺少=>考试名称!");
        return NO;
    }
    
    if(!_productId || _productId.length == 0){
        NSLog(@"配置缺少=>产品ID!");
        return NO;
    }
    if(!_productName || _productName.length == 0){
        NSLog(@"配置缺少=>产品ID!");
        return NO;
    }

    return YES;
}
#pragma mark 保存到本地用户配置中
-(BOOL)saveToDefaults{
    //拼装字典转化为JSON串
    NSDictionary *dict = @{__kAppSettings_keys_examId:(_examId ? _examId : @""),
                           __kAppSettings_keys_examCode:(_examCode ? _examCode : @0),
                           __kAppSettings_keys_examName:(_examName ? _examName : @""),
                           __kAppSettings_keys_productId:(_productId ? _productId : @""),
                           __kAppSettings_keys_productName:(_productName ? _productName : @"") };
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
    if(err){
        NSLog(@"配置转为JSON错误=>%@",err);
        return NO;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //保存数据
    [userDefaults setObject:data forKey:__kAppSettings_defaults];
    //同步数据
    [userDefaults synchronize];
    
    return YES;
}
@end
