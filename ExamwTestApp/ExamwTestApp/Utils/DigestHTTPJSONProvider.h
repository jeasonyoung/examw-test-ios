//
//  DigestHTTPJSON.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/15.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//摘要认证的HTTPJSON数据请求提供者
@interface DigestHTTPJSONProvider : NSObject

//静态函数
+(instancetype)shareProvider;

//设置后台线程处理任务
@property(nonatomic,assign)BOOL shouldExecuteAsBackgroundTask;

//检查网络状态
-(void)checkNetworkStatus:(void(^)(BOOL statusValue))handler;

//post数据请求
-(void)postDataWithUrl:(NSString *)url
            parameters:(NSDictionary *)dict
               success:(void(^)(NSDictionary *result))successHandler
                  fail:(void(^)(NSString *err))failHandler;

//get数据请求
-(void)getDataWithUrl:(NSString *)url
           parameters:(NSDictionary *)dict
              success:(void(^)(NSDictionary *result))successHandler
                 fail:(void(^)(NSString *err))failHandler;
@end
