//
//  HttpUtils.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, HttpUtilsMethod){
    HttpUtilsMethodGET = 0,
    HttpUtilsMethodPOST
};

//HTTP工具类
@interface HttpUtils : NSObject
//检测网络状态
+(void)netWorkStatus:(void(^)(BOOL statusValue))status;
//JSON数据请求
+(void)JSONDataWithUrl:(NSString *)url
                Method:(HttpUtilsMethod)method
            Parameters:(NSDictionary *)parameters
               Success:(void(^)(id json))success
                  Fail:(void(^)(NSError *error))fail;
//JSON摘要认证数据请求
+(void)JSONDataDigestWithUrl:(NSString *)url
                      Method:(HttpUtilsMethod)method
                  Parameters:(NSDictionary *)parameters
                    Username:(NSString *)username
                    Password:(NSString *)password
                     Success:(void(^)(id json))success
                        Fail:(void(^)(NSError *error))fail;
@end
