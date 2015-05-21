//
//  DownloadDao.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "DownloadDao.h"
#import "DaoHelpers.h"

#import "AppClientSync.h"

#import "HttpUtils.h"
#import "AppConstants.h"
#import "JSONCallback.h"

#import "PaperUtils.h"

//下载服务器数据成员变量
@interface DownloadDao (){
    DaoHelpers *_daoHelpers;
    
}
@end

//下载服务器数据实现
@implementation DownloadDao

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _daoHelpers = [[DaoHelpers alloc]init];
    }
    return self;
}

#pragma mark 下载处理
-(void)downloadWithIgnoreCode:(BOOL)ignoreCode
                    andResult:(void (^)(BOOL, NSString *))handler{
    //数据库访问队列
    FMDatabaseQueue *queue = _daoHelpers.dbQueue;
    if(!queue){
        NSLog(@"数据库访问队列初始化失败!");
        if(handler)handler(NO, @"初始化本地数据库错误!");
        return;
    }
    
    NSLog(@"准备开始下载服务器数据...");
    //初始化请求参数
    AppClientSync *reqParameters = [[AppClientSync alloc]init];
    reqParameters.ignoreCode = ignoreCode;
    
    //服务器错误处理块
    void(^servErrorHandler)(NSString *) = ^(NSString *err){
        NSLog(@"服务器异常:%@", err);
        if(!handler)return;
        //开启新线程处理服务器错误
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            handler(NO,err);
        });
    };
    
    //试卷下载成功处理块
    void(^paperSuccessHandler)(NSDictionary *) = ^(NSDictionary *data){
        //在主线程中开启子线程处理
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block NSString *msg;
            @try {
                //反馈数据反序列化
                JSONCallback *callback = [JSONCallback callbackWithDict:data];
                if(!callback.success){
                    NSLog(@"下载试卷错误:%@", callback.msg);
                    if(handler)handler(NO,callback.msg);
                    return;
                }
                NSLog(@"开始解析试卷数据...");
                NSArray *arrays = callback.data;
                if(arrays && arrays.count > 0){
                    NSLog(@"准备将试卷数据写入本地数据库...");
                    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                        @try {
                            for(NSDictionary *dict in arrays){
                                if(!dict || dict.count == 0) continue;
                                [self updatePaperWithDb:db andData:dict];
                            }
                        }
                        @catch (NSException *exception) {
                            *rollback = YES;
                            msg = [NSString stringWithFormat:@"试卷数据写入本地数据库异常:%@",exception];
                            NSLog(@"%@",msg);
                            if(handler)handler(NO, msg);
                        }
                    }];
                }
                if(handler)handler(YES,nil);
            }
            @catch (NSException *exception) {
                msg = [NSString stringWithFormat:@"异常:%@", exception];
                NSLog(@"%@", msg);
                if(handler)handler(NO,msg);
            }
        });
    };
    //科目下载消息处理
    void(^subjectDownloadMsgHandler)(BOOL, NSString *,NSString *) = ^(BOOL result, NSString *msg, NSString *examCode){
        if(!result){//
            if(handler)handler(result,msg);
            return;
        }
        //下载试题数据
        NSLog(@"准备开始下载试题数据...");
        @try {
            static NSString *query_sql = @"select createTime from tbl_papers order by createTime desc limit 0,1";
            FMDatabase *db = [FMDatabase databaseWithPath:queue.path];
            [db open];
            reqParameters.startTime = [db stringForQuery:query_sql];
            [db close];
        }
        @catch (NSException *exception) {
            NSLog(@"查询最后同步时间异常:%@", exception);
        }
        //下载试题数据
        [HttpUtils JSONDataWithUrl:_kAPP_API_PAPERS_URL method:HttpUtilsMethodPOST parameters:[reqParameters serialize]
                          progress:nil success:paperSuccessHandler fail:servErrorHandler];
    };
    //科目下载成功处理块
    void(^subjectSuccessHandler)(NSDictionary *) = ^(NSDictionary *data){
        //在主线程中开启子线程处理
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block NSString *msg;
            @try {
                //
                JSONCallback *callback = [JSONCallback callbackWithDict:data];
                if(!callback.success){
                    NSLog(@"服务器发生错误:%@", callback.msg);
                    subjectDownloadMsgHandler(NO, callback.msg, nil);
                    return;
                }
                NSLog(@"开始解析科目数据...");
                NSDictionary *examDict = callback.data;
                if(!examDict || examDict.count == 0){
                    msg = @"没有考试数据下载...";
                    NSLog(@"%@",msg);
                    subjectDownloadMsgHandler(NO, msg, nil);
                    return;
                }
                //所属考试代码
                NSString *examCode = [examDict objectForKey:@"code"];
                if(!examCode || examCode.length == 0){
                    msg = @"未能获取考试代码!";
                    NSLog(@"%@",msg);
                    subjectDownloadMsgHandler(NO, msg, nil);
                    return;
                }
                //科目数据集合
                NSArray *subjectArrays = [examDict objectForKey:@"subjects"];
                if(!subjectArrays || subjectArrays.count == 0){
                    msg = @"未能获取科目数据!";
                    NSLog(@"%@", msg);
                    subjectDownloadMsgHandler(NO, msg, nil);
                    return;
                }
                //数据库操作
                [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                    @try {
                        //重置科目状态
                        [db executeUpdate:@"update tbl_subjects set status = 0 "];
                        //科目数据更新
                        for(NSDictionary *subject in subjectArrays){
                            if(!subject || subject.count == 0) continue;
                            [self updateSubjectWithDb:db andExamCode:examCode andData:subject];
                        }
                    }
                    @catch (NSException *exception) {
                        *rollback = YES;
                        msg = [NSString stringWithFormat:@"科目数据写入本地数据库异常:%@",exception];
                        NSLog(@"%@",msg);
                        subjectDownloadMsgHandler(NO, msg, nil);
                    }
                }];
                //完成
                subjectDownloadMsgHandler(YES, nil, examCode);
            }
            @catch (NSException *exception) {
                msg = [NSString stringWithFormat:@"异常:%@", exception];
                NSLog(@"%@", msg);
                subjectDownloadMsgHandler(NO, msg, nil);
            }
        });
    };
    //开始检查网络
    [HttpUtils checkNetWorkStatus:^(BOOL statusValue) {
        NSLog(@"检查网络[%d]...",statusValue);
        if (statusValue) {
            //下载考试科目
            NSLog(@"开始下载考试科目...");
            [HttpUtils JSONDataWithUrl:_kAPP_API_SUBJECTS_URL method:HttpUtilsMethodPOST parameters:[reqParameters serialize]
                              progress:nil success:subjectSuccessHandler fail:servErrorHandler];
        }
    }];
}

//更新科目数据
-(void)updateSubjectWithDb:(FMDatabase *)db andExamCode:(NSString *)examCode andData:(NSDictionary *)dict{
    //查询是否存在
    static NSString *query_sql = @"SELECT COUNT(*) FROM tbl_subjects WHERE code = ? AND examCode = ?";
    //插入
    static NSString *insert_sql = @"INSERT INTO tbl_subjects(code,name,status,examCode) VALUES(?,?,?,?)";
    //更新
    static NSString *update_sql = @"UPDATE tbl_subjects SET name = ?, status = ? WHERE code = ? AND examCode = ?";
    
    NSString *code = [dict objectForKey:@"code"],*name = [dict objectForKey:@"name"];
    
    if([db intForQuery:query_sql,code,examCode] > 0){//存在数据，更新
        
        BOOL result = [db executeUpdate:update_sql, name, [NSNumber numberWithBool:YES], code, examCode];
        NSLog(@"更新科目数据[%@,%@]=>%@",code,name,result ? @"成功" : @"失败");
        
    }else{//不存在，插入
        
        BOOL result = [db executeUpdate:insert_sql,code,name,[NSNumber numberWithBool:YES], examCode];
        NSLog(@"插入科目数据[%@,%@]=>%@",code,name,result ? @"成功" : @"失败");
        
    }
}

//更新试卷数据
-(void)updatePaperWithDb:(FMDatabase *)db andData:(NSDictionary *)dict{
    //查询数据存在数据
    static NSString *query_sql = @"SELECT COUNT(*) FROM tbl_papers WHERE id = ?";
    //插入
    static NSString *insert_sql = @"INSERT INTO tbl_papers(id,title,type,total,content,createTime,subjectCode) VALUES(?,?,?,?,?,?,?)";
    //更新
    static NSString *update_sql = @"UPDATE tbl_papers SET title = ?,type = ?,total = ?,content = ?,createTime = ?,subjectCode = ? WHERE id = ?";
    //
    NSString *paperId = [dict objectForKey:@"id"],*title = [dict objectForKey:@"title"],*content = [dict objectForKey:@"content"],*subjectCode = [dict objectForKey:@"subjectCode"];
    NSNumber *type = [dict objectForKey:@"type"],*total = [dict objectForKey:@"total"];
    NSDate *createTime = [dict objectForKey:@"createTime"];
    
    //加密试题内容
    NSString *encryptContent = [PaperUtils encryptPaperContent:content andPassword:paperId];
    if([db intForQuery:query_sql, paperId] > 0){//存在，更新
       
        BOOL result = [db executeUpdate:update_sql,title,type,total,encryptContent,createTime,subjectCode,paperId];
        NSLog(@"更新试题数据[%@,%@]=>%@", paperId,title,result ? @"成功" : @"失败");
        
    }else{//不存在，插入
        
        BOOL result = [db executeUpdate:insert_sql,paperId,title,type,total,encryptContent,createTime,subjectCode];
        NSLog(@"插入试题数据[%@,%@]=>%@", paperId,title,result ? @"成功" : @"失败");
        
    }
}
@end
