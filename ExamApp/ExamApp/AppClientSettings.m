//
//  AppClientSettings.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AppClientSettings.h"
#import "NSString+Date.h"

//客户端唯一标示
#define __kAppClientSettings_id @"357070005327186"
//客户端名称
#define __kAppClientSettings_name @"焚题库 iOS v%fBate"
//客户端软件版本
#define __kAppClientSettings_version 1.0//
//客户端类型代码
#define __kAppClientSettings_typeCode 7//
//客户端考试EN简称
#define __kAppClientSettings_examAbbr @"cy"//考试代码
//默认考试日期
#define __kAppClientSettings_defaultExamDate @"2015-04-15"//默认考试日期
//考试日期键名
#define __kAppClientSettings_examDateKey @"_exam_date_key"//考试日期储存键名
//产品信息键名
#define __kAppClientSettings_ProductsKey @"_current_products"//当前产品存储键名
//产品ID键名
#define __kAppClientSettings_ProductIDKey @"ProductID"//
//产品名称键名
#define __kAppClientSettings_ProductNameKey @"ProductName"//

//考试日期格式
#define __kAppClientSettings_examDateFormate @"yyyy-MM-dd"//
//频道(固定值 根据考试来填写)
#define __kAppClientSettings_channel @"jzs1"//
//认证用户名
#define __kAppClientSettings_digestUserName @"admin"//账号
//认证密码
#define __kAppClientSettings_digestPassword @"123456"//密码

//服务器地址前缀
#define __kAppClientSettings_hostPrefix @"http://localhost:8080/examw-test"//
//同步产品数据URL
#define __kAppClientSettings_syncProductsSuffix @"/sync/products/%@"//
//注册提交URL
#define __kAppClientSettings_registerPostSuffix @"/api/m/user/register"//
//登录提交URL
#define __kAppClientSettings_loginPostSuffix @"/api/m/user/login"//
//注册码验证URL
#define __kAppClientSettings_appRegisterCodeSuffix @"/api/m/app/register"//
//同步产品下考试科目URL
#define __kAppClientSettings_syncExamSubjectSuffix @"/api/m/sync/exams"//
//同步产品下的试卷数据URL
#define __kAppClientSettings_syncPapersSuffix @"/api/m/sync/papers"

//首页地址
#define __kAppClientSettings_homeUrl @"http://m.examw.com/"//
//考试指南地址
#define __kAppClientSettings_guideUrl @"http://m.examw.com/cy/"//
//论坛地址
#define __kAppClientSettings_bbsUrl @"http://bbs.examw.com/forum-37-1.html"//

//应用程序设置实现
@implementation AppClientSettings
#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //常量部分
        _appClientID = __kAppClientSettings_id;
        _appClientName = [NSString stringWithFormat:__kAppClientSettings_name,__kAppClientSettings_version];
        _appClientVersion = __kAppClientSettings_version;
        _appClientTypeCode = __kAppClientSettings_typeCode;
        _appClientChannel = __kAppClientSettings_channel;
        _digestUsername = __kAppClientSettings_digestUserName;
        _digestPassword = __kAppClientSettings_digestPassword;
        
        //设置数据
        _appClientExamDate = [self loadExamDate];
        //加载产品数据
        [self loadProducts];
        
        //数据同步部分
        NSString *syncProductsSuffix = [NSString stringWithFormat:__kAppClientSettings_syncProductsSuffix,__kAppClientSettings_examAbbr];
        _syncProductsUrl = [NSString stringWithFormat:@"%@%@",__kAppClientSettings_hostPrefix,syncProductsSuffix];
        _registerPostUrl = [NSString stringWithFormat:@"%@%@",__kAppClientSettings_hostPrefix,__kAppClientSettings_registerPostSuffix];
        _loginPostUrl = [NSString stringWithFormat:@"%@%@",__kAppClientSettings_hostPrefix,__kAppClientSettings_loginPostSuffix];
        _appRegCodeValidUrl = [NSString stringWithFormat:@"%@%@",__kAppClientSettings_hostPrefix,__kAppClientSettings_appRegisterCodeSuffix];
        _syncExamSubjecstUrl = [NSString stringWithFormat:@"%@%@",__kAppClientSettings_hostPrefix,__kAppClientSettings_syncExamSubjectSuffix];
        _syncPapersUrl = [NSString stringWithFormat:@"%@%@",__kAppClientSettings_hostPrefix,__kAppClientSettings_syncPapersSuffix];
    
        //链接地址部分
        _homeUrl = __kAppClientSettings_homeUrl;
        _guideUrl = __kAppClientSettings_guideUrl;
        _bbsUrl = __kAppClientSettings_bbsUrl;
    }
    return self;
}
//加载考试日期
-(NSDate *)loadExamDate{
    //从持久化数据中加载考试日期数据
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:__kAppClientSettings_examDateKey];
    if(data && data.length > 0){
        NSString *dateValue = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if(dateValue && dateValue.length > 0){
            return [dateValue toDateWithFormat:__kAppClientSettings_examDateFormate];
        }
    }
    //从默认数据中加载考试日期
    if(__kAppClientSettings_defaultExamDate && __kAppClientSettings_defaultExamDate.length > 0){
        return [__kAppClientSettings_defaultExamDate toDateWithFormat:__kAppClientSettings_examDateFormate];
    }
    //未能找到考试日期
    return nil;
}
#pragma mark 更新考试日期
-(void)updateWithExamDate:(NSDate *)examDate{
    if(!examDate) return;
    //转化为字符串
    NSString *dateValue = [NSString stringFromDate:examDate withDateFormat:__kAppClientSettings_examDateFormate];
    if(dateValue && dateValue.length > 0){
        //转化为字节数组
        NSData *dateValueData = [dateValue dataUsingEncoding:NSUTF8StringEncoding];
        //初始化持久化
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //以字节数组保存到持久化数据
        [userDefaults setObject:dateValueData forKey:__kAppClientSettings_examDateKey];
        //更新持久化数据
        [userDefaults synchronize];
        //更新当前考试日期
        _appClientExamDate = [dateValue toDateWithFormat:__kAppClientSettings_examDateFormate];
    }
}
//加载产品
-(void)loadProducts{
    //初始化赋值
    _appClientProductID = _appClientProductName = nil;
    //从持久化中加载产品二进制数据.
    NSData *data = [[NSUserDefaults standardUserDefaults]dataForKey:__kAppClientSettings_ProductsKey];
    if(data && data.length > 0){
        NSError *err = nil;
        //反JSON序列化
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments
                                                               error:&err];
        if(err){//反序列化失败
            NSLog(@"loadProducts－json-error:%@",err);
            return;
        }
        if(!dict || dict.count == 0) return;
        //加载产品ID
        id obj_value = [dict objectForKey:__kAppClientSettings_ProductIDKey];
        if(obj_value && [obj_value isKindOfClass:[NSString class]]){
            _appClientProductID = (NSString *)obj_value;
        }
        //加载产品名称
        obj_value = [dict objectForKey:__kAppClientSettings_ProductNameKey];
        if(obj_value && [obj_value isKindOfClass:[NSString class]]){
            _appClientProductName = (NSString *)obj_value;
        }
    }
    
}
#pragma mark 更新产品
-(void)updateWithProductID:(NSString *)productId andProductName:(NSString *)productName{
    if(productId && productId.length > 0 && productName && productName.length > 0){
        //产品数据拼装为数据字典
        NSDictionary *dict = @{__kAppClientSettings_ProductIDKey:productId,__kAppClientSettings_ProductNameKey:productName};
        //将数据字典序列化为JSON字节数组
        NSError *err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&err];
        if(err){
            NSLog(@"updateWithProductID:andProductName:->json error:%@", err);
            return;
        }
        //初始化持久
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //更新数据
        [userDefaults setObject:data forKey:__kAppClientSettings_ProductsKey];
        //同步数据
        [userDefaults synchronize];
        //
        _appClientProductID = productId;
        _appClientProductName = productName;
    }
}
#pragma mark 静态函数入口
//静态对象
static AppClientSettings *instance = nil;
//静态初始化
+(instancetype)clientSettings{
    if(!instance){
        instance = [[self alloc] init];
    }
    return instance;
}
@end
