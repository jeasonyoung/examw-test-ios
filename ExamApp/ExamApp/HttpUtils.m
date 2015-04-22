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
               Success:(void (^)(NSDictionary *))success
                  Fail:(void (^)(NSString *))fail{
    [self JSONDataWithUrl:url
                   Method:method
                  Headers:nil
               Parameters:parameters
                 Username:nil
                 Password:nil
                 Counters:0
                  Success:^(NSDictionary *json) {
                        if(success){
                          success(json);
                        }
                     }
                     Fail:^(NSString * error) {
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
                     Success:(void (^)(NSDictionary *))success
                        Fail:(void (^)(NSString *))fail{
    [self JSONDataWithUrl:url
                   Method:method
                  Headers:nil
               Parameters:parameters
                 Username:username
                 Password:password
                 Counters:0
                  Success:^(NSDictionary *json) {
                      if(success){
                          success(json);
                      }
                     }
                     Fail:^(NSString *error) {
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
               Success:(void (^)(NSDictionary *))success
                  Fail:(void (^)(NSString *))fail{
    //URL为空时退出；
    if(url && url.length == 0)return;
    //URL转成UTF-8
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", @"text/javascript", nil];
    manager.responseSerializer = responseSerializer;
    //请求方式
    switch(method){
        case HttpUtilsMethodGET:{//GET请求方式
            [manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //请求成功
                if(success){
                    success([self responseToDictionary:operation.responseString]);
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
                    fail([self createStringWithError:error]);
                }
            }];
            break;
        }
        case HttpUtilsMethodPOST:{//POST请求方式
            [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //请求成功
                if(success){
                    success([self responseToDictionary:operation.responseString]);
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
                    fail([self createStringWithError:error]);
                }
            }];
            break;
        }
    }
}
+(NSDictionary *)responseToDictionary:(NSString *)response{
    NSLog(@"response=>%@",response);
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    if(error){
        NSLog(@"反馈数据转换为JSON时发生异常[%@]=>json:%@",response,error);
    }
    return [dict mutableCopy];
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
                    Fail:(void (^)(NSString *))fail{
    //失败代码:401
    if(401 == [error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode]){
        if(counters > __k_httputils_digest_max_count){
            if(fail){
                fail([self createStringWithError:error]);
            }
            return;
        }
        //摘要认证处理
        NSString *authc = operation.response.allHeaderFields[__k_httputils_authenticate_header];
        if(authc && authc.length > 0){
            NSLog(@"authc => %@", authc);
            NSString *realm = [self loadParameterWithAuthenticate:authc FieldName:__k_httputils_digest_realm],
            *nonce = [self loadParameterWithAuthenticate:authc FieldName:__k_httputils_digest_nonce],
            *cnonce = [NSString stringWithFormat:@"%08d",(int)(arc4random())],
            *opaque = [self loadParameterWithAuthenticate:authc FieldName:__k_httputils_digest_opaque];
            NSString *nc = [NSString stringWithFormat:@"%08d",(counters + 1)];
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
            
            //NSLog(@"authz=>%@",authz);
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
    }else if(fail){//非401失败处理
        fail([self createStringWithError:error]);
    }
}
//创建错误信息
+(NSString *)createStringWithError:(NSError *)error{
    return [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
}
//从Authc中获取字段的内容
+(NSString *)loadParameterWithAuthenticate:(NSString *)authc FieldName:(NSString *)name{
    if(!authc || authc.length == 0 || !name || name.length == 0)return nil;
    NSString *pattern = [NSString stringWithFormat:@"%@=((.+?,)|((.+?)$))", name];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if(regex){
        NSTextCheckingResult *firstMatch = [regex firstMatchInString:authc options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, authc.length)];
        if(firstMatch && firstMatch.numberOfRanges > 0){
            NSRange resultRange = [firstMatch rangeAtIndex:1];
            if(!NSEqualRanges(resultRange, NSMakeRange(NSNotFound, 0))){
                NSString *result = [authc substringWithRange:resultRange];
                //NSLog(@"regex-pattern:%@  => %@",pattern, result);
                if(result && result.length > 0){
                    if([result hasSuffix:@","]){//是否以，号结尾
                        result = [result substringToIndex:(result.length - 1)];
                        //NSLog(@"=>%@",result);
                    }
                    if(result.length > 1 && [result hasPrefix:@"\""]){
                        result = [result substringFromIndex:1];
                        //NSLog(@"=>%@",result);
                    }
                    if(result.length > 0 && [result hasSuffix:@"\""]){
                        result = [result substringToIndex:(result.length - 1)];
                        //NSLog(@"=>%@",result);
                    }
                    return result;
                }
            }
        }
    }else{
        NSLog(@"regex-error:%@",error);
    }
    return nil;
}
@end
