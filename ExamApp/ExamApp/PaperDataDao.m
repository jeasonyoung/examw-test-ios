//
//  PaperDataDao.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperDataDao.h"
#import <FMDB/FMDB.h>
#import "PaperData.h"

#import "AESCrypt.h"
#import "NSString+Date.h"

#define __kPaperDataDao_encryptprefix @"0x"
#define __kPaperDataDao_dateFormatter @"yyyy-MM-dd HH:mm:ss"
//试卷数据操作类成员变量
@interface PaperDataDao (){
    FMDatabase *_db;
}
@end
//试卷数据操作类实现
@implementation PaperDataDao
#pragma mark 初始化
-(instancetype)initWithDb:(FMDatabase *)db{
    if(self = [super init]){
        _db = db;
    }
    return self;
}
#pragma mark 根据科目和试卷类型分页数据集合
-(NSArray *)loadPapersWithSubjectCode:(NSString *)subjectCode
                            PaperType:(PaperType)type
                                Index:(NSUInteger)index
                           RowsOfPage:(NSUInteger)rowsOfPage{
    if(!subjectCode || subjectCode.length == 0 || !_db || ![_db tableExists:__k_paperdatadao_tableName]) return nil;
    if(index < 1) index = 1;
    if(rowsOfPage <= 0) rowsOfPage = 10;
    
    NSMutableString *query_sql = [NSMutableString stringWithString:@"select id,title,type,total,subjectCode,createTime "];
    [query_sql appendString:@" from tbl_papers "];
    [query_sql appendString:@" where subjectCode = ? and type = ? "];
    [query_sql appendString:@" order by createTime desc "];
    [query_sql appendFormat:@" limit %d,%d", (int)((index - 1) * rowsOfPage), (int)rowsOfPage];
    
    NSMutableArray *arrys = [NSMutableArray arrayWithCapacity:rowsOfPage];
    FMResultSet *rs = [_db executeQuery:query_sql,subjectCode,[NSNumber numberWithInteger:type]];
    while ([rs next]) {
        PaperData *data = [[PaperData alloc] init];
        data.code = [rs stringForColumn:@"id"];
        data.title = [rs stringForColumn:@"title"];
        data.type = [rs intForColumn:@"type"];
        data.total = [rs intForColumn:@"total"];
        data.subjectCode = [rs stringForColumn:@"subjectCode"];
        NSString *strCreateTime = [rs stringForColumn:@"createTime"];
        if(strCreateTime && strCreateTime.length > 0){
            data.createTime = [strCreateTime toDateWithFormat:__kPaperDataDao_dateFormatter];
        }
        [arrys addObject:data];
    }
    [rs close];
    return arrys;
}
#pragma mark 根据试题ID加载试题所属科目代码
-(NSString *)loadSubjectCodeWithPaperCode:(NSString *)code{
    if(!_db)return nil;
    NSString *query_sql = @"select subjectCode from tbl_papers where id = ? limit 0,1";
    return [_db stringForQuery:query_sql,code];
}
#pragma mark 根据试卷ID加载试卷内容
-(PaperReview *)loadPaperContentWithCode:(NSString *)code{
    if(!_db || !code || code.length == 0 || ![_db tableExists:__k_paperdatadao_tableName])return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select %@,%@ from %@ where %@ = ?",
                           __k_paperdata_fields_content,__k_paperdata_fields_total,
                           __k_paperdatadao_tableName,__k_paperdata_fields_code];
    //加载加密的试卷内容
    NSString *encrypt_content;
    NSNumber *totalNum;
    FMResultSet *rs = [_db executeQuery:query_sql, code];
    while ([rs next]) {
        encrypt_content = [rs stringForColumn:__k_paperdata_fields_content];
        totalNum = [NSNumber numberWithInteger:[rs intForColumn:__k_paperdata_fields_total]];
        break;
    }
    [rs close];
    if(!encrypt_content || encrypt_content.length == 0) return nil;
    //解密试卷内容
    NSString *json = [self decryptPaperContentWithEncrypt:encrypt_content Password:code];
    //反序列化试卷内容
    PaperReview *review = [[PaperReview alloc] initWithJSON:json];
    if(review && totalNum){
        review.total = totalNum.integerValue;
    }
    return review;
}
#pragma mark 加载最新的数据同步时间
-(NSString *)loadLastSyncTime{
    if(_db && [_db tableExists:__k_paperdatadao_tableName]){
        NSString *query_sql = [NSString stringWithFormat:@"select %@ from %@ order by %@ desc limit 0,1",
                               __k_paperdata_fields_createTime,__k_paperdatadao_tableName,__k_paperdata_fields_createTime];
        return [_db stringForQuery:query_sql];
    }
    return nil;
}
#pragma mark 同步数据
-(void)syncWithData:(NSArray *)data{
    if(!data || data.count == 0) return;
    if(!_db || ![_db tableExists:__k_paperdatadao_tableName]) return;
    for (NSDictionary *dict in data) {
        if(!dict || dict.count == 0) continue;
        PaperData *paperData = [[PaperData alloc] initWithDictionary:dict];
        if(paperData && paperData.code && paperData.code.length > 0){
            [self syncDataWithPaperData:paperData];
        }
    }
}
//同步试卷数据
-(BOOL)syncDataWithPaperData:(PaperData *)data{
    BOOL result = NO;
    if(!data || !_db)return result;
    NSString *encryptContent = [self encryptPaperContent:data];
    //查询试卷是否存在
    NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ?",
                           __k_paperdatadao_tableName,__k_paperdata_fields_code];
    long total = [_db longForQuery:query_sql,data.code];
    if(total > 0){//更新试卷数据
        NSString *update_sql = [NSString stringWithFormat:@"update %@ set %@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ? where %@ = ?",
                                __k_paperdatadao_tableName,
                                __k_paperdata_fields_title,
                                __k_paperdata_fields_type,
                                __k_paperdata_fields_total,
                                __k_paperdata_fields_content,
                                __k_paperdata_fields_createTime,
                                __k_paperdata_fields_subjectCode,
                                __k_paperdata_fields_code];
        result = [_db executeUpdate:update_sql,data.title,[NSNumber numberWithInteger:data.type],[NSNumber numberWithInteger:data.total],encryptContent,data.createTime,data.subjectCode,data.code];
    }else{//新增试卷数据
        NSString *insert_sql = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@,%@,%@,%@) values(?,?,?,?,?,?,?)",
                                __k_paperdatadao_tableName,
                                __k_paperdata_fields_code,
                                __k_paperdata_fields_title,
                                __k_paperdata_fields_type,
                                __k_paperdata_fields_total,
                                __k_paperdata_fields_content,
                                __k_paperdata_fields_createTime,
                                __k_paperdata_fields_subjectCode];
        result = [_db executeUpdate:insert_sql,data.code,data.title,[NSNumber numberWithInteger:data.type],[NSNumber numberWithInteger:data.total],encryptContent,data.createTime,data.subjectCode];
    }
    return result;
}
//加密试卷内容
-(NSString *)encryptPaperContent:(PaperData *)paper{
    if(!paper || !paper.content) return nil;
    if(paper.content.length == 0) return paper.content;
    if([paper.content hasPrefix:__kPaperDataDao_encryptprefix]){//密文数据
        return paper.content;
    }
    return [NSString stringWithFormat:@"%@%@",__kPaperDataDao_encryptprefix,[AESCrypt encryptFromString:paper.content password:paper.code]];
}
//解密试卷内容
-(NSString *)decryptPaperContentWithEncrypt:(NSString *)encryptContent Password:(NSString *)pwd{
    if(!encryptContent) return nil;
    if(encryptContent.length == 0) return encryptContent;
    if(![encryptContent hasPrefix:__kPaperDataDao_encryptprefix]){//未加密数据
        return encryptContent;
    }
    NSString *content = [encryptContent substringFromIndex:(__kPaperDataDao_encryptprefix.length)];
    return [AESCrypt decryptFromString:content password:pwd];
}
@end
