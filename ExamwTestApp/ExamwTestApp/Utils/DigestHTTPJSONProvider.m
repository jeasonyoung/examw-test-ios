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

#import "SSZipArchive.h"

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
        //[self setResponseSerializerForJSON];
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

//设置返回JSON的解析器
-(void)setResponseSerializerForJSON{
    //返回ContextType设置
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", @"text/javascript", nil];
    _manager.responseSerializer = responseSerializer;
}

#pragma mark POST提交数据
-(void)postDataWithUrl:(NSString *)url
            parameters:(NSDictionary *)dict
               success:(void (^)(NSDictionary *))successHandler
                  fail:(void (^)(NSString *))failHandler{
    NSLog(@"POST数据请求[%@]...",url);
    [self setResponseSerializerForJSON];
    [self dataRequestWithUrl:url method:@"POST" parameters:dict success:successHandler fail:failHandler];
}

#pragma mark GET提交数据
-(void)getDataWithUrl:(NSString *)url
           parameters:(NSDictionary *)dict
              success:(void (^)(NSDictionary *))successHandler
                 fail:(void (^)(NSString *))failHandler{
    NSLog(@"GET数据请求[%@]...",url);
    [self setResponseSerializerForJSON];
    [self dataRequestWithUrl:url method:@"GET" parameters:dict success:successHandler fail:failHandler];
}

#pragma mark post下载Zip请求
-(void)postDownloadZipWithUrl:(NSString *)url
                   parameters:(NSDictionary *)dict
                     progress:(void (^)(CGFloat))processHandler
                      success:(void (^)(id))successHandler
                         fail:(void (^)(NSString *))failHandler{
    //URL
    NSParameterAssert(url);
    //设置请求提交JSON格式
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //设置返回二进制格式
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //afn请求成功处理block
    void(^afnDownloadSuccessHandler)(AFHTTPRequestOperation *,id) = ^(AFHTTPRequestOperation *operation,id responseObject){
        //指定下载文件保存的路径
        NSString *downloadTempDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        //时间戳
        NSString *timesp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
        NSString *tempFileName = [NSString stringWithFormat:@"p%@.zip", timesp];
        NSString *zipPath = [downloadTempDir stringByAppendingPathComponent:tempFileName];
        
        NSLog(@"下载文件临时存储路径=>%@", zipPath);
        //保存下载文件
        NSData *data = operation.responseData;
        if(data && [data writeToFile:zipPath atomically:YES]){//开始解压
            NSLog(@"保存下载文件成功!=>%@",zipPath);
            //初始化文件管理器
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            //解压路径
            NSString *tempUnzipDir = [NSString stringWithFormat:@"p%@", timesp];
            NSString *unzipPath = [downloadTempDir stringByAppendingPathComponent:tempUnzipDir];
            //解压
            if([SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath]){
                NSLog(@"文件[%@]解压成功=>%@", zipPath, unzipPath);
                NSString *dataPath = nil;
                //列出解压文件夹中的所有文件
                NSArray *files = [fileMgr contentsOfDirectoryAtPath:unzipPath error:nil];
                for(NSString * fileName in files){
                    NSLog(@"解压文件夹中文件名=>%@", fileName);
                    if([fileName hasSuffix:@".json"]){
                        dataPath = [unzipPath stringByAppendingPathComponent:fileName];
                        if([fileMgr fileExistsAtPath:dataPath]){
                            NSLog(@"找到JSON数据存储文件=>%@", dataPath);
                            break;
                        }
                    }
                }
                //加载数据文件
                NSData *data = [NSData dataWithContentsOfFile:dataPath];
                if(data){
                    NSLog(@"已读取文件＝>%@", dataPath);
                    NSError *err = nil;
                    id jsonObj = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&err];
                    if(jsonObj && !err){
                        NSLog(@"解析JSON成功！%@",[jsonObj class]);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(successHandler) successHandler(jsonObj);
                        });
                    }else{
                        NSLog(@"解析JSON失败＝>%@", err);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(failHandler) failHandler([err localizedDescription]);
                        });
                    }
                }
                //删除解压目录
                BOOL delUnzipDirResult = [fileMgr removeItemAtPath:unzipPath error:nil];
                NSLog(@"删除解压目录[%@]%@!", unzipPath, (delUnzipDirResult ? @"成功" : @"失败"));
            }else{
                NSLog(@"文件解压失败=>%@",zipPath);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(failHandler) failHandler(@"没有更新!");
                });
            }
            //删除下载压缩文件
            BOOL delZipFileResult = [fileMgr removeItemAtPath:zipPath error:nil];
            NSLog(@"删除下载文件[%@]%@!", zipPath, (delZipFileResult ? @"成功" : @"失败"));
        }else{
            NSLog(@"下载失败!");
        }
    };
    
    
    //下载数据
    AFHTTPRequestOperation *op = [_manager POST:url
                                     parameters:dict
                                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            //异步线程处理
                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                                                //调用下载处理块
                                                afnDownloadSuccessHandler(operation, responseObject);
                                            });
                                        }
                                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            @try {
                                                if(!failHandler)return;
                                                
                                                NSLog(@"response:%@", operation.responseString);
                                                NSLog(@"error:%@", error);
                                                failHandler(error.localizedDescription);
                                            }
                                            @catch (NSException *exception) {
                                                NSLog(@"请求失败处理发生异常:%@", exception);
                                            }
                                        }];
    //进度条
    if(processHandler && op){
        //设置下载进程块代码
        [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            //设置进度条的百分比
            CGFloat precent = (CGFloat)totalBytesRead / totalBytesExpectedToRead;
            //
            NSLog(@"下载进度:%f", precent);
            //
            processHandler(precent);
        }];
    }
    //当为后台线程任务时
    if(op && _shouldExecuteAsBackgroundTask){
        //APP后台运行
        [op setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
            //停止请求队列
            [_manager.operationQueue cancelAllOperations];
        }];
    }
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
