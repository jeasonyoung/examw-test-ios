//
//  HttpUtils.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "HttpUtils.h"
#import "AFNetworkReachabilityManager.h"
#import "AFHTTPRequestOperationManager.h"

#import "AppConstants.h"
#import "SecureUtils.h"

#define __kHttpUtils_authenticate @"WWW-Authenticate"//HTTP摘要认证头信息
#define __kHttpUtils_authorization @"Authorization"//HTTP摘要认证请求头信息

#define __kHttpUtils_digest_maxCount 3//http摘要认证请求次数

#define __kHttpUtils_digest_realm @"realm"//
#define __kHttpUtils_digest_nonce @"nonce"//
#define __kHttpUtils_digest_opaque @"opaque"//
#define __kHttpUtils_digest_qop @"auth"//
#define __kHttpUtils_digest_get @"GET"//
#define __kHttpUtils_digest_post @"POST"//
//HTTP操作工具实现
@implementation HttpUtils
#pragma mark 检测网络状态
+(void)checkNetWorkStatus:(void (^)(BOOL status))handler{
    NSLog(@"检测网络状态...");
    //检测网络连接的单例，网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(handler){
            handler(status > AFNetworkReachabilityStatusNotReachable);
        }
    }];
    //如果要检测网络状态的变化，必须用检测管理器的单列的StartMonitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
//Digest headers
static NSDictionary *digestHeaders;

#pragma mark JSON数据请求
+(void)JSONDataWithUrl:(NSString *)url
                method:(HttpUtilsMethod)method
            parameters:(NSDictionary *)parameters
              progress:(void (^)(long long, long long))progressHandler
               success:(void (^)(NSDictionary *success))successHandler
                  fail:(void (^)(NSString *fail))failHandler{
    //URL为空时退出
    if(!url || url.length == 0)return;
    NSLog(@"开始访问网络:%@",url);
    //调用JSON摘要认证
    [self JSONDigestDataWithUrl:url
                         method:method
                        headers:digestHeaders
                     parameters:parameters
                       username:__kAPP_API_USERNAME
                       password:__kAPP_API_PASSWORD
                       counters:0
                       progress:progressHandler
                        success:successHandler
                           fail:failHandler];
}

//JSON摘要认证
+(void)JSONDigestDataWithUrl:(NSString *)url
                      method:(HttpUtilsMethod)method
                     headers:(NSDictionary *)headers
                  parameters:(NSDictionary *)parameters
                    username:(NSString *)username
                    password:(NSString *)password
                    counters:(NSUInteger)counters
                    progress:(void (^)(long long, long long))progressHandler
                     success:(void(^)(NSDictionary *))successHandler
                        fail:(void(^)(NSString *))failHandler{
    
    //URL为空时退出
    if(!url || url.length == 0)return;
    //URL转为UTF－8
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //初始化AF网络请求
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //POST请求时JSON的设置
    if(method == HttpUtilsMethodPOST){
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    //添加头信息
    if(headers && headers.count > 0){
        NSArray *headFields = headers.allKeys;
        for(NSString *headField in headFields){
            //头关键字为空
            if(!headField || headField.length == 0){
                continue;
            }
            //头关键字内容为空
            NSString *value = [headers objectForKey:headField];
            if(!value || value.length == 0){
                continue;
            }
            //设置头信息
            [manager.requestSerializer setValue:value forHTTPHeaderField:headField];
        }
    }
    //设置返回信息的JSON格式
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", @"text/javascript", nil];
    manager.responseSerializer = responseSerializer;
    //
    //处理block块
    //afn请求成功处理
    void(^afnSuccessHandler)(AFHTTPRequestOperation *,id) = ^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"请求成功:%@",responseObject);
        if(successHandler){
            NSDictionary *dict = nil;
            @try {
                NSString *response = operation.responseString;
                NSLog(@"response:%@",response);
                NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
                if(err){
                    NSLog(@"response反序列化为JSON时异常:%@",err);
                    return;
                }
            }
            @catch (NSException *exception) {
                NSLog(@"JSON解析反馈数据时异常:%@", exception);
            }
            @finally {
                successHandler(dict);
            }
        }
    };
    //afn请求失败处理
    void(^afnFailHandler)(AFHTTPRequestOperation *,NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"请求失败:%@", error);
        //digest认证失败
        if([error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode] == 401){
            if(counters > __kHttpUtils_digest_maxCount){//超过最大认证请求次数
                if(failHandler){
                    failHandler([NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]]);
                }
                return;
            }
            NSString *authz = [self createAuthorizationHeaderWithOperation:operation url:url method:method
                                                                  username:username password:password counters:counters];
            if(!authz || authz.length == 0){
                NSLog(@"生成摘要认证的Authz信息失败!");
                return;
            }
            //摘要认证头信息
            digestHeaders = @{__kHttpUtils_authorization : authz};
            //重新调用认证
            NSLog(@"第[%d]次认证:%@", (int)(counters + 1), digestHeaders);
            [self JSONDigestDataWithUrl:url method:method headers:digestHeaders parameters:parameters
                               username:username password:password counters:(counters+1)
                               progress:progressHandler
                                success:successHandler fail:failHandler];
        }else if(failHandler){
            failHandler([NSString stringWithFormat:@"%@", error.localizedDescription]);
        }
    };
    //
    AFHTTPRequestOperation *req;
    //请求方式
    switch (method) {
        case HttpUtilsMethodGET:{//GET
            NSLog(@"GET:%@",url);
            req = [manager GET:url parameters:parameters success:afnSuccessHandler failure:afnFailHandler];
            break;
        }
        case HttpUtilsMethodPOST:{//POST
            NSLog(@"POST:%@", url);
            req = [manager POST:url parameters:parameters success:afnSuccessHandler failure:afnFailHandler ];
            break;
        }
        default:{
            NSLog(@"请求方式:[%d]不能被识别!", (int)method);
            break;
        }
    }
    //
    if(req && progressHandler){
        [req setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            NSLog(@"下载进度:%ld => %lld/ %lld", (long)bytesRead, totalBytesRead, totalBytesExpectedToRead);
            progressHandler(totalBytesRead, totalBytesExpectedToRead);
        }];
    }
}
//创建authorization头信息
+(NSString *)createAuthorizationHeaderWithOperation:(AFHTTPRequestOperation *)operation
                                                url:(NSString *)url
                                             method:(HttpUtilsMethod)method
                                           username:(NSString *)username
                                           password:(NSString *)password
                                           counters:(NSUInteger)counters{
    //获取摘要信息
    NSString *authc = operation.response.allHeaderFields[__kHttpUtils_authenticate];
    if(authc && authc.length > 0){
        NSLog(@"authc:%@",authc);
        NSString *realm = [self valueWithAuthenticate:authc parameterName:__kHttpUtils_digest_realm],
        *nonce = [self valueWithAuthenticate:authc parameterName:__kHttpUtils_digest_nonce],
        *cnonce = [NSString stringWithFormat:@"%08d",(int)(arc4random())],
        *opaque = [self valueWithAuthenticate:authc parameterName:__kHttpUtils_digest_opaque];
        NSString *nc = [NSString stringWithFormat:@"%08d",(int)(counters + 1)];
        NSString *ha1 = [SecureUtils hexMD5WithText:[NSString stringWithFormat:@"%@:%@:%@",username,realm,password]],
        *ha2 = [SecureUtils hexMD5WithText:[NSString stringWithFormat:@"%@:%@",(method == HttpUtilsMethodGET ? __kHttpUtils_digest_get : __kHttpUtils_digest_post),url]],
        *response = [SecureUtils hexMD5WithText:[NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",ha1,nonce,nc,cnonce,__kHttpUtils_digest_qop,ha2]];
        
        
        NSMutableString *authz = [NSMutableString stringWithString:@"Digest "];
        [authz appendFormat:@"username=\"%@\",", username];
        [authz appendFormat:@"realm=\"%@\",",realm];
        [authz appendFormat:@"nonce=\"%@\",",nonce];
        [authz appendFormat:@"uri=\"%@\",",url];
        [authz appendFormat:@"qop=\"%@\",",__kHttpUtils_digest_qop];
        [authz appendFormat:@"nc=\"%@\",",nc];
        [authz appendFormat:@"cnonce=\"%@\",",cnonce];
        [authz appendFormat:@"response=\"%@\",",response];
        [authz appendFormat:@"opaque=\"%@\"",opaque];
        
        NSLog(@"authz:%@",authz);
        
        return authz;
    }
    return nil;
}
//从Authenticate中获取参数值
+(NSString *)valueWithAuthenticate:(NSString *)authc parameterName:(NSString *)parameterName{
    if(!authc || authc.length == 0 || !parameterName || parameterName.length == 0)return nil;
    NSError *error;
    NSString *pattern = [NSString stringWithFormat:@"%@=((.+?,)|((.+?)$))", parameterName];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if(error){
        NSLog(@"获取[%@]值的正则表达式[%@]时异常:%@", parameterName, pattern, error);
        return nil;
    }
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
                NSLog(@"%@=>%@",parameterName, result);
                return result;
            }
        }
    }
    return nil;
}
@end
