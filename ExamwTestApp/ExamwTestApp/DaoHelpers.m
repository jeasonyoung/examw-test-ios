//
//  DaoHelpers.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "DaoHelpers.h"
#import "SecureUtils.h"

#import "AppDelegate.h"
#import "AppSettings.h"
#import "UserAccount.h"

#define __kDaoHelpers_nologin @"_nologin_"//未登录用户名

#define __kDaoHelpers_dbName @"exam_$%@$%@.db"//数据库名称格式
//DAO操作工具基础类成员变量
@interface DaoHelpers (){
    NSString *_username;
    NSString *_productId;
}
@end

//DAO操作工具基础类实现
@implementation DaoHelpers

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        NSLog(@"初始化DAO工具类...");
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        if(app){
            //产品ID
            if(app.appSettings){
                _productId = app.appSettings.productId;
                NSLog(@"当前产品ID=>%@",_productId);
            }
            //当前用户
            if(app.currentUser){
                _username = app.currentUser.username;
                NSLog(@"当前用户=>%@",_username);
            }
        }
    }
    return self;
}

#pragma mark 静态初始化
+(instancetype)daoHelpers{
    return [[self alloc] init];
}

#pragma mark 创建数据库操作对象
-(FMDatabase *)createDatabase{
    NSString *path = [self loadDatabasePath];
    if(path && path.length > 0){
        NSLog(@"创建数据库[%@]操作对象...",path);
        return [FMDatabase databaseWithPath:path];
    }
    return nil;
}

#pragma mark 创建数据库操作队列.
-(FMDatabaseQueue *)createDatabaseQueue{
    NSString *path = [self loadDatabasePath];
    if(path && path.length > 0){
        NSLog(@"创建数据库[%@]操作对象队列...",path);
        return [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return nil;
}

//创建数据库路径
-(NSString *)loadDatabasePath{
    NSLog(@"加载数据库路径=>(productId:%@,username:%@)...",_productId,_username);
    if(!_productId || _productId.length == 0) return nil;
    static NSMutableDictionary *dbPathCache;
    if(!dbPathCache){
        dbPathCache = [NSMutableDictionary dictionary];
    }
    //用户键
    NSString *userKey = (_username && _username.length > 0) ? [SecureUtils hexMD5WithText:_username] : __kDaoHelpers_nologin;
    //db文件名
    NSString *dbName = [NSString stringWithFormat:__kDaoHelpers_dbName,userKey,_productId];
    NSString *path = [dbPathCache objectForKey:dbName];
    if(!path || path.length == 0){
        //根路径
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        //路径
        path = [doc stringByAppendingPathComponent:dbName];
        NSLog(@"数据库路径>>>%@",path);
        //文件管理器
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if(![fileMgr fileExistsAtPath:path]){//文件不存在
            if(_username && _username.length > 0){//已登陆
                //未登录数据库路径
                NSString *nologinDbPath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:__kDaoHelpers_dbName,
                                                                               __kDaoHelpers_nologin, _productId]];
                NSLog(@"未登录数据库文件路径:%@", nologinDbPath);
                if([fileMgr fileExistsAtPath:nologinDbPath]){//文件存在，复制一份到当前数据库路径
                    NSError *err;
                    if([fileMgr copyItemAtPath:nologinDbPath toPath:path error:&err]){//复制文件成功
                        //添加到缓存
                        [dbPathCache setObject:path forKey:dbName];
                        //
                        return path;
                    }
                    NSLog(@"复制文件失败:%@ [%@=>%@]",err, nologinDbPath,path);
                }
            }
            //创建数据库及其脚本
            if(![self createDbTablesWithPath:path]){
                NSLog(@"创建表结构失败！");
                return nil;
            }
            //添加到缓存
            [dbPathCache setObject:path forKey:dbName];
        }
    }
    return path;
}
//创建执行表结构
-(BOOL)createDbTablesWithPath:(NSString *)path{
    __block BOOL result = NO;
    if(!path || path.length == 0) return result;
    //执行SQL脚本
    @try {
        NSArray *sqls = [self createDbTableSQL];
        if(sqls && sqls.count > 0){
            FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
            [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                @try {
                    for(NSString *sql in sqls){
                        NSLog(@"执行脚本:%@",sql);
                        [db executeUpdate:sql];//执行脚本
                    }
                    result = YES;
                }
                @catch (NSException *exception) {
                    *rollback = YES;
                    NSLog(@"执行SQL异常:%@", exception);
                }
            }];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"创建数据文件异常:%@", exception);
    }
    return result;
}
//创建表结构脚本
-(NSArray *)createDbTableSQL{
    //create sql
    return @[
             //1.创建科目表[status(0-不可用,1-可用)]
             @"CREATE TABLE tbl_subjects(code TEXT,name TEXT,status INTEGER DEFAULT 1,examCode INTEGER DEFAULT 0, CONSTRAINT PK_tbl_subjects PRIMARY KEY(code,examCode));",
             
             //2.创建试卷表
             @"CREATE TABLE tbl_papers(id TEXT PRIMARY KEY,title TEXT,type INTEGER DEFAULT 0,total INTEGER DEFAULT 0,content TEXT,createTime TIMESTAMP DEFAULT (datetime('now', 'localtime')),subjectCode TEXT);",
             //2.1创建索引
             @"CREATE INDEX tbl_papers_subjectCode_idx ON  tbl_papers(subjectCode);",
             
             //3.创建试题收藏表[status(0-删除，1-收藏)]
             @"CREATE TABLE tbl_favorites(id TEXT PRIMARY KEY,subjectCode TEXT,itemId TEXT,itemType INTEGER DEFAULT 0,content TEXT,status INTEGER DEFAULT 1,createTime TIMESTAMP DEFAULT (datetime('now', 'localtime')),sync INTEGER DEFAULT 0);",
             //3.1创建索引
             @"CREATE INDEX tbl_favorites_subjectCode_idx ON tbl_favorites(subjectCode)",
             
             //4.创建做卷记录表[status(0-未做完，1-已做完)][sync(0-未同步,1-已同步)]
             @"CREATE TABLE tbl_paperRecords(id TEXT PRIMARY KEY,paperId TEXT,status INTEGER DEFAULT 0,score FLOAT DEFAULT 0,rights INTEGER DEFAULT 0,useTimes INTEGER DEFAULT 0,createTime TIMESTAMP DEFAULT (datetime('now', 'localtime')),lastTime TIMESTAMP DEFAULT (datetime('now', 'localtime')),sync INTEGER DEFAULT 0);",
             //4.1创建索引
             @"CREATE INDEX tbl_paperRecords_paperId_idx ON tbl_paperRecords(paperId)",
             
             //5.创建做题记录表[status(0-错误，1-正确)]
             @"CREATE TABLE tbl_itemRecords(id TEXT PRIMARY KEY,paperRecordId TEXT,structureId TEXT,itemId TEXT,itemType INTEGER DEFAULT 0,content TEXT,answer TEXT,status INTEGER DEFAULT 0,score FLOAT DEFAULT 0,useTimes INTEGER DEFAULT 0,createTime TIMESTAMP DEFAULT (datetime('now', 'localtime')),lastTime TIMESTAMP DEFAULT (datetime('now', 'localtime')),sync INTEGER DEFAULT 0);",
             //5.1创建索引
             @"CREATE INDEX tbl_itemRecords_paperRecordId_idx ON tbl_itemRecords(paperRecordId)"
            ];
}
@end
