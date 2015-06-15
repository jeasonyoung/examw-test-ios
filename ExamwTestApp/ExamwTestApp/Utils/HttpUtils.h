//
//  HttpUtils.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//HTTP提交方式
typedef NS_ENUM(NSUInteger, HttpUtilsMethod){
    //GET
    HttpUtilsMethodGET = 0,
    //POST
    HttpUtilsMethodPOST
};
//HTTP操作工具
@interface HttpUtils : NSObject

//检测网络状态
+(void)checkNetWorkStatus:(void(^)(BOOL statusValue))handler;
//JSON数据请求
+(void)JSONDataWithUrl:(NSString *)url
                method:(HttpUtilsMethod)method
            parameters:(NSDictionary *)parameters
              progress:(void(^)(long long totalBytesRead, long long totalBytesExpectedToRead))progressHandler
               success:(void(^)(NSDictionary *))successHandler
                  fail:(void(^)(NSString *))failHandler;
@end
