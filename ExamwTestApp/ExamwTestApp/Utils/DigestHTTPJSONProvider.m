//
//  DigestHTTPJSON.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/15.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "DigestHTTPJSONProvider.h"

#import "AFNetworking.h"
#import "AppConstants.h"

//摘要认证的HTTPJSON数据请求提供者成员变量
@interface DigestHTTPJSONProvider (){
    AFHTTPRequestOperationManager *_manager;
}
@end
//摘要认证的HTTPJSON数据请求提供者实现
@implementation DigestHTTPJSONProvider

#pragma mark 重载初始化
-(instancetype)init{
    if((self = [super init]) && (!_manager)){
        //初始化AF管理器
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //身份认证
        NSURLCredential *credential = [NSURLCredential credentialWithUser:__kAPP_API_USERNAME
                                                                 password:__kAPP_API_PASSWORD
                                                              persistence:NSURLCredentialPersistenceForSession];
        _manager.credential = credential;
        //返回ContextType设置
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", @"text/javascript", nil];
        _manager.responseSerializer = responseSerializer;
    }
    return self;
}

#pragma mark 设置后台线程任务
-(void)setShouldExecuteAsBackgroundTask:(BOOL)shouldExecuteAsBackgroundTask{
    if(_shouldExecuteAsBackgroundTask != shouldExecuteAsBackgroundTask){
        _shouldExecuteAsBackgroundTask = shouldExecuteAsBackgroundTask;
        NSLog(@"设置后台线程任务:%d", _shouldExecuteAsBackgroundTask);
    }
}

#pragma mark 静态单例
+(instancetype)shareProvider{
    static DigestHTTPJSONProvider *_shareProvider;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareProvider = [[self alloc] init];
        NSLog(@"初始化网络访问对象...");
    });
    _shareProvider.shouldExecuteAsBackgroundTask = NO;
    return _shareProvider;
}

#pragma mark 检查网络
-(void)checkNetworkStatus:(void (^)(BOOL))handler{
    if(handler){
        AFNetworkReachabilityManager *_reachabilityMgr = _manager.reachabilityManager;
        if(_reachabilityMgr){
            NSLog(@"检测网络状态...");
            //设置网络状态回调block
            [_reachabilityMgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                NSLog(@"当前网络状态:%d", (int)status);
                handler(status > AFNetworkReachabilityStatusNotReachable);
            }];
            //开始监控网络状态
            [_reachabilityMgr startMonitoring];
        }
    }
}

#pragma mark POST提交数据
-(void)postDataWithUrl:(NSString *)url
            parameters:(NSDictionary *)dict
               success:(void (^)(NSDictionary *))successHandler
                  fail:(void (^)(NSString *))failHandler{
    NSLog(@"POST数据请求[%@]...",url);
    [self dataRequestWithUrl:url method:@"POST" parameters:dict success:successHandler fail:failHandler];
}

#pragma mark GET提交数据
-(void)getDataWithUrl:(NSString *)url
           parameters:(NSDictionary *)dict
              success:(void (^)(NSDictionary *))successHandler
                 fail:(void (^)(NSString *))failHandler{
    NSLog(@"GET数据请求[%@]...",url);
    [self dataRequestWithUrl:url method:@"GET" parameters:dict success:successHandler fail:failHandler];
}

//数据请求
-(void)dataRequestWithUrl:(NSString *)url
                   method:(NSString *)method
               parameters:(NSDictionary *)dict
                  success:(void (^)(NSDictionary *))successHandler
                     fail:(void (^)(NSString *))failHandler{
    //URL
    NSParameterAssert(url);
    //METHOD
    NSParameterAssert(method);
    //afn请求成功处理block
    void(^afnSuccessHandler)(AFHTTPRequestOperation *,id) = ^(AFHTTPRequestOperation *operation,id responseObject){
        @try {
            if(!successHandler)return;
            
            NSString *response = operation.responseString;
            NSLog(@"response:%@", response);
            if(responseObject && [responseObject isKindOfClass:[NSDictionary class]]){
                successHandler(responseObject);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"请求成功处理发生异常:%@", exception);
        }
    };
    //afn请求失败处理block
    void(^afnFailHandler)(AFHTTPRequestOperation *,NSError *) = ^(AFHTTPRequestOperation *operation,NSError *error){
        @try {
            if(!failHandler)return;
            
            NSLog(@"response:%@", operation.responseString);
            NSLog(@"error:%@", error);
            failHandler(error.localizedDescription);
        }
        @catch (NSException *exception) {
            NSLog(@"请求失败处理发生异常:%@", exception);
        }
    };
    //转化为大写
    method = method.uppercaseString;
    AFHTTPRequestOperation *reqOperation;
    if([method isEqualToString:@"POST"]){//POST
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        reqOperation = [_manager POST:url parameters:dict success:afnSuccessHandler failure:afnFailHandler];
    }else{//GET
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        reqOperation = [_manager GET:url parameters:dict success:afnSuccessHandler failure:afnFailHandler];
    }
    //当为后台线程任务时
    if(reqOperation && _shouldExecuteAsBackgroundTask){
        //APP后台运行
        [reqOperation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
            //停止请求队列
            [_manager.operationQueue cancelAllOperations];
        }];
    }
}
@end
