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

#import "DigestHTTPJSONProvider.h"
#import "AppConstants.h"
#import "JSONCallback.h"

#import "PaperUtils.h"

//下载服务器数据成员变量
@interface DownloadDao (){
    FMDatabaseQueue *_dbQueue;
    DigestHTTPJSONProvider *_provider;
}
@end

//下载服务器数据实现
@implementation DownloadDao

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //1.初始化数据操作
        DaoHelpers *daoHelpers = [[DaoHelpers alloc]init];
        _dbQueue = [daoHelpers createDatabaseQueue];
        if(!_dbQueue){
            NSLog(@"数据库访问队列初始化失败!");
        }
        //2.初始化网络提供者
        _provider = [DigestHTTPJSONProvider shareProvider];
    }
    return self;
}

#pragma mark 加载下载试卷的最后时间
-(NSString *)loadDownloadLastTime{
    //数据库访问队列
    if(!_dbQueue){
        NSLog(@"数据库访问队列初始化失败!");
        return nil;
    }
    //从试卷表中查询最新的试卷发布时间
    __block NSString *lastTime = @"";
    [_dbQueue inDatabase:^(FMDatabase *db) {
        static NSString *query_sql = @"select createTime from tbl_papers order by createTime desc limit 0,1";
        lastTime = [db stringForQuery:query_sql];
    }];
    //返回试卷发布时间
    return lastTime;
}

#pragma mark 下载处理
-(void)downloadWithIgnoreCode:(BOOL)ignoreCode
                    andResult:(void (^)(BOOL, NSString *))handler{
    //数据库访问队列
    if(!_dbQueue){
        NSLog(@"数据库访问队列初始化失败!");
        if(handler)handler(NO, @"初始化本地数据库错误!");
        return;
    }
    NSLog(@"准备开始下载服务器数据...");
    //检查网络
    [_provider checkNetworkStatus:^(BOOL statusValue) {
        if(!statusValue){
            handler(NO,@"请检查网络!");
            return;
        }
        //0.初始化请求参数
        AppClientSync *reqParameters = [[AppClientSync alloc]init];
        reqParameters.ignoreCode = ignoreCode;
        //1.下载考试科目
        [self downloadSubjectWithParameter:reqParameters andResult:^(BOOL status, NSString *msg) {
            if(!status){//下载科目失败
                handler(status, msg);
                return;
            }
            //2.下载试卷
            [self downloadPapersWithParameter:reqParameters andResult:handler];
        }];
    }];
}
//下载科目
-(void)downloadSubjectWithParameter:(AppClientSync *)reqParameters andResult:(void (^)(BOOL status, NSString *msg))handler{
    @try {
        NSParameterAssert(reqParameters);
        if(!_dbQueue)return;
        NSLog(@"开始下载科目数据...");
        //网络下载
        [_provider postDataWithUrl:_kAPP_API_SUBJECTS_URL parameters:[reqParameters serialize] success:^(NSDictionary *result) {
            __block NSString *msg = @"";
            @try {
                JSONCallback *callback = [JSONCallback callbackWithDict:result];
                if(!callback.success){
                    NSLog(@"服务器发生错误:%@", callback.msg);
                    if(handler){handler(NO, callback.msg);}
                    return;
                }
                NSLog(@"开始解析科目数据...");
                NSDictionary *examDict;
                if(callback.data && [callback.data isKindOfClass:[NSDictionary class]]){
                    examDict = (NSDictionary *)callback.data;
                }
                if(!examDict || examDict.count == 0){
                    msg = @"没有考试数据下载...";
                    NSLog(@"%@",msg);
                    if(handler){handler(NO, msg);}
                    return;
                }
                //所属考试代码
                NSNumber *examCode;
                id examCodeValue = [examDict objectForKey:@"code"];
                if(!examCodeValue || examCodeValue == [NSNull null]){
                    msg = @"未能获取考试代码!";
                    NSLog(@"%@",msg);
                    if(handler){handler(NO, msg);}
                    return;
                }
                if([examCodeValue isKindOfClass:[NSNumber class]]){
                    examCode = (NSNumber *)examCodeValue;
                }else if([examCodeValue isKindOfClass:[NSString class]]){
                    examCode = [NSNumber numberWithInteger:[((NSString *)examCodeValue) integerValue]];
                }else{
                    msg = @"未能获取考试代码失败!";
                    NSLog(@"格式转换失败:%@",msg);
                    if(handler){handler(NO, msg);}
                    return;
                }
                //科目数据集合
                NSArray *subjectArrays = [examDict objectForKey:@"subjects"];
                if(!subjectArrays || subjectArrays.count == 0){
                    msg = @"未能获取科目数据!";
                    NSLog(@"%@", msg);
                    if(handler){handler(NO, msg);}
                    return;
                }
                //数据库操作
                [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                    @try {
                        //重置科目状态
                        [db executeUpdate:@"update tbl_subjects set status = 0 "];
                        //科目数据更新
                        NSLog(@"共有[%d]条科目数据更新...",(int)subjectArrays.count);
                        for(NSDictionary *subject in subjectArrays){
                            if(!subject || subject.count == 0) continue;
                            [self updateSubjectWithDb:db andExamCode:examCode andData:subject];
                        }
                    }
                    @catch (NSException *exception) {
                        *rollback = YES;
                        msg = [NSString stringWithFormat:@"科目数据写入本地数据库异常:%@",exception];
                        NSLog(@"%@",msg);
                        if(handler){handler(NO, msg);}
                    }
                }];
                //完成
                if(handler){handler(YES, nil);}
            }
            @catch (NSException *exception) {
                msg = [NSString stringWithFormat:@"异常:%@", exception];
                NSLog(@"%@", msg);
                if(handler){handler(NO, msg);}
            }
        } fail:^(NSString *err) {
            NSLog(@"下载科目失败:%@", err);
            if(handler){handler(NO,@"下载科目失败!");};
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"下载科目异常:%@", exception);
        if(handler){handler(NO,@"下载科目失败!");};
    }
}

//更新科目数据
-(void)updateSubjectWithDb:(FMDatabase *)db andExamCode:(NSNumber *)examCode andData:(NSDictionary *)dict{
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

//下载试卷
-(void)downloadPapersWithParameter:(AppClientSync *)reqParameters andResult:(void (^)(BOOL status, NSString *msg))handler{
    @try {
        NSParameterAssert(reqParameters);
        if(!_dbQueue)return;
        //下载试卷数据
        NSLog(@"准备开始下载试卷数据...");
        //从试卷表中查询最新的试卷发布时间
        reqParameters.startTime = [self loadDownloadLastTime]; //lastTime;
        //下载试卷数据成功
        void(^successHandler)(id) = ^(id result){
            NSLog(@"准备解析下载试卷...");
            if(result && [result isKindOfClass:[NSArray class]]){
                NSArray *arrays = (NSArray *)result;
                if(arrays && arrays.count > 0){
                    NSLog(@"共下载[%d]套试卷...", (int)arrays.count);
                    NSLog(@"准备将试卷数据写入本地数据库...");
                    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback){
                        @try {
                            for(NSDictionary *dict in arrays){
                                if(!dict || dict.count == 0) continue;
                                [self updatePaperWithDb:db andData:dict];
                            }
                        }
                        @catch (NSException *exception) {
                            *rollback = YES;
                            NSLog(@"试卷数据写入本地数据库异常:%@",exception);
                            if(handler)handler(NO, @"试卷本地存储失败!");
                        }
                    }];
                    if(handler)handler(YES,nil);
                }else{
                    NSLog(@"没有下载到试卷!");
                    if(handler)handler(NO,@"没有下载到试卷!");
                }
            }else{
                NSLog(@"JSON数据格式不正确，无法解析!");
                if(handler)handler(NO,@"下载数据格式不正确，无法解析!");
            }
        };
        //下载进度
        void(^downloadProcessHandler)(CGFloat) = ^(CGFloat precent){
            NSLog(@"下载进度=>%f", (precent * 100));
        };
        //下载试卷数据失败
        void(^failHandler)(NSString *) = ^(NSString *err){
            NSLog(@"下载试卷失败:%@", err);
            if(handler){handler(NO,err);};
        };
        //下载试卷数据ZIP压缩文件包
        [_provider postDownloadZipWithUrl:_kAPP_API_PAPERS_URL
                               parameters:[reqParameters serialize]
                                 progress:downloadProcessHandler
                                  success:successHandler
                                     fail:failHandler];
    }
    @catch (NSException *exception) {
        NSLog(@"下载试卷异常:%@", exception);
        if(handler){handler(NO,@"下载试卷失败!");};
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
