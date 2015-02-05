//
//  HttpUtils.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "HttpUtils.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "AESCrypt.h"

#define __k_httputils_digest_max_count 3//http摘要认证请求的次数
#define __k_httputils_authenticate_header @"WWW-Authenticate"//http摘要认证头信息
#define __k_httputils_authorization_header @"Authorization"//http摘要认证请求头信息

#define __k_httputils_digest_realm @"realm"//
#define __k_httputils_digest_nonce @"nonce"//
#define __k_httputils_digest_opaque @"opaque"//
#define __k_httputils_digest_qop @"auth"//
#define __k_httputils_digest_get @"GET"//
#define __k_httputils_digest_post @"POST"//
//HTTP工具类实现类
@implementation HttpUtils
#pragma mark 检测网络状态
+(void)netWorkStatus:(void (^)(BOOL status))handler{
    //如果要检测网络状态的变化，必须用检测管理器的单列的StartMonitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    //检测网络连接的单例，网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(handler){
            handler(status > AFNetworkReachabilityStatusNotReachable);
        }
    }];
}
#pragma mark JSON数据请求
+(void)JSONDataWithUrl:(NSString *)url
                Method:(HttpUtilsMethod)method
            Parameters:(NSDictionary *)parameters
               Success:(void (^)(id))success
                  Fail:(void (^)(NSError *))fail{
    [self JSONDataWithUrl:url Method:method Headers:nil Parameters:parameters Username:nil Password:nil Counters:0 Success:^(id json) {
        if(success){
            success(json);
        }
    } Fail:^(NSError * error) {
        if(fail){
            fail(error);
        }
    }];
}
#pragma mark JSON摘要认证数据请求
+(void)JSONDataDigestWithUrl:(NSString *)url
                      Method:(HttpUtilsMethod)method
                  Parameters:(NSDictionary *)parameters
                    Username:(NSString *)username
                    Password:(NSString *)password
                     Success:(void (^)(id))success
                        Fail:(void (^)(NSError *))fail{
    [self JSONDataWithUrl:url Method:method Headers:nil Parameters:parameters Username:username Password:password Counters:0 Success:^(id json) {
        if(success){
            success(json);
        }
    } Fail:^(NSError *error) {
        if(fail){
            fail(error);
        }
    }];
};
//数据处理
+(void)JSONDataWithUrl:(NSString *)url
                Method:(HttpUtilsMethod)method
               Headers:(NSDictionary *)headers
            Parameters:(NSDictionary *)parameters
              Username:(NSString *)username
              Password:(NSString *)password
              Counters:(int)counters
               Success:(void (^)(id))success
                  Fail:(void (^)(NSError *))fail{
    //URL为空时退出；
    if(url && url.length == 0)return;
    //初始化AF网络请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    if(method == HttpUtilsMethodPOST){//POST请求时JSON的设置
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    //添加头信息
    if(headers && headers.count > 0){
        for(NSString *head in headers.allKeys){
            if([head isEqual:[NSNull null]] || head.length == 0) continue;//头关键字为空时
            if([headers objectForKey:head] == [NSNull null]) continue;//头关键字内容为空时
            //设置头信息
            [manager.requestSerializer setValue:[headers objectForKey:head] forHTTPHeaderField:head];
        }
    }
    //设置返回信息的JSON格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //请求方式
    switch(method){
        case HttpUtilsMethodGET:{//GET请求方式
            [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //请求成功
                if(success){
                    success(responseObject);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //请求失败
                if(username && password){
                    [self httpDigestHandler:operation
                                      Error:error
                                        Url:url
                                     Method:method
                                 Parameters:parameters
                                   Username:username
                                   Password:password
                                   Counters:counters
                                    Success:success
                                       Fail:fail];
                }else if(fail){//失败处理
                    fail(error);
                }
            }];
            break;
        }
        case HttpUtilsMethodPOST:{//POST请求方式
            [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //请求成功
                if(success){
                    success(responseObject);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //请求失败
                if(username && password){
                    [self httpDigestHandler:operation
                                      Error:error
                                        Url:url
                                     Method:method
                                 Parameters:parameters
                                   Username:username
                                   Password:password
                                   Counters:counters
                                    Success:success
                                       Fail:fail];
                }else if(fail){//失败处理
                    fail(error);
                }
            }];
            break;
        }
    }
}
//摘要处理
+(void)httpDigestHandler:(AFHTTPRequestOperation *)operation
                   Error:(NSError *)error
                     Url:(NSString *)url
                  Method:(HttpUtilsMethod)method
              Parameters:(NSDictionary *)parameters
                Username:(NSString *)username
                Password:(NSString *)password
                Counters:(int)counters
                 Success:(void (^)(id))success
                    Fail:(void (^)(NSError *))fail{
    //失败代码:401
    if(401 == [error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode]){
        if(counters > __k_httputils_digest_max_count){
            if(fail){
                fail(error);
            }
            return;
        }
        //摘要认证处理
        NSString *authc = operation.response.allHeaderFields[__k_httputils_authenticate_header];
        if(authc && authc.length > 0){
            NSLog(@"authc => %@", authc);
            NSString *realm = [self loadParameterWithAuthenticate:authc FieldName:__k_httputils_digest_realm],
            *nonce = [self loadParameterWithAuthenticate:authc FieldName:__k_httputils_digest_nonce],
            *cnonce = [NSString stringWithFormat:@"%08d",arc4random()],
            *opaque = [self loadParameterWithAuthenticate:authc FieldName:__k_httputils_digest_opaque];
            NSString *nc = [NSString stringWithFormat:@"%08d",counters];
            NSString *ha1 = [AESCrypt md5SumFromString:[NSString stringWithFormat:@"%@:%@:%@",username,realm,password]],
            *ha2 = [AESCrypt md5SumFromString:[NSString stringWithFormat:@"%@:%@",(method == HttpUtilsMethodGET ? __k_httputils_digest_get : __k_httputils_digest_post),url]],
            *response = [AESCrypt md5SumFromString:[NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",ha1,nonce,nc,cnonce,__k_httputils_digest_qop,ha2]];
            
            NSMutableString *authz = [NSMutableString stringWithString:@"Digest "];
            [authz appendFormat:@"username=\"%@\",", username];
            [authz appendFormat:@"realm=\"%@\",",realm];
            [authz appendFormat:@"nonce=\"%@\",",nonce];
            [authz appendFormat:@"uri=\"%@\",",url];
            [authz appendFormat:@"qop=\"%@\",",__k_httputils_digest_qop];
            [authz appendFormat:@"nc=\"%@\",",nc];
            [authz appendFormat:@"cnonce=\"%@\",",cnonce];
            [authz appendFormat:@"response=\"%@\",",response];
            [authz appendFormat:@"opaque=\"%@\"",opaque];
            
            NSLog(@"authz=>%@",authz);
            [self JSONDataWithUrl:url
                           Method:method
                          Headers:@{__k_httputils_authorization_header:[authz copy]}
                       Parameters:parameters
                         Username:username
                         Password:password
                         Counters:(counters + 1)
                          Success:success
                             Fail:fail];
        }
    }
    //失败处理
    if(fail){
        fail(error);
    }
}
//从Authc中获取字段的内容
+(NSString *)loadParameterWithAuthenticate:(NSString *)authc FieldName:(NSString *)name{
    if(!authc || authc.length == 0 || !name || name.length == 0)return nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@=((.+?,)|((.+?)$))", name]
                                                                           options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators)
                                                                             error:nil];
    NSArray *matches = [regex matchesInString:authc options:0 range:NSMakeRange(0, authc.length)];
    if(matches.count > 0){
        return matches[0];
    }
    return nil;
}
@end
