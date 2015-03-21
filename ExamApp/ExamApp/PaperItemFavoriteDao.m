//
//  PaperItemFavoriteDao.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemFavoriteDao.h"
#import <FMDB/FMDB.h>
#import "NSString+Date.h"
#import "NSDate+TimeZone.h"
#import "PaperItemFavorite.h"

#import "AESCrypt.h"

#define __k_paperitemfavoritedao_tableName @"tbl_favorites"
#define __k_paperitemfavoritedao_encryptprefix @"0x"

//试题收藏数据操作成员变量
@interface PaperItemFavoriteDao (){
    FMDatabase *_db;
}
@end
//试题收藏数据操作实现
@implementation PaperItemFavoriteDao
#pragma mark 初始化
-(instancetype)initWithDb:(FMDatabase *)db{
    if(self = [super init]){
        _db = db;
    }
    return self;
}
#pragma mark 统计科目代码下的收藏
-(NSInteger)totalWithSubjectCode:(NSString *)subjectCode{
    if(subjectCode && subjectCode.length > 0 && _db && [_db tableExists:__k_paperitemfavoritedao_tableName]){
        NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ? and %@ = ?",
                               __k_paperitemfavoritedao_tableName,
                               __k_paperitemfavorite_fields_status,
                               __k_paperitemfavorite_fields_subjectCode];
        return [_db intForQuery:query_sql,[NSNumber numberWithBool:YES],subjectCode];
    }
    return 0;
}
#pragma mark 加载收藏数据
-(PaperItemFavorite *)loadFavorite:(NSString *)favoriteCode{
    if(!_db || !favoriteCode || favoriteCode.length == 0 || ![_db tableExists:__k_paperitemfavoritedao_tableName]) return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@ desc limit 0,1",
                           __k_paperitemfavoritedao_tableName,
                           __k_paperitemfavorite_fields_code,
                           __k_paperitemfavorite_fields_createTime];
    PaperItemFavorite *favorite;
    FMResultSet *rs = [_db executeQuery:query_sql,favoriteCode];
    while ([rs next]) {
        favorite = [self createFavorite:rs];
        break;
    }
    [rs close];
    return favorite;
}
#pragma mark 根据科目代码和试题ID加载收藏
-(PaperItemFavorite *)loadFavoriteWithSubjectCode:(NSString *)subjectCode ItemCode:(NSString *)itemCode{
    if(!_db || !subjectCode || subjectCode.length == 0 || !itemCode || itemCode.length == 0) return nil;
    if(![_db tableExists:__k_paperitemfavoritedao_tableName]) return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? and %@ = ? order by %@ desc limit 0,1",
                           __k_paperitemfavoritedao_tableName,
                           __k_paperitemfavorite_fields_subjectCode,
                           __k_paperitemfavorite_fields_itemCode,
                           __k_paperitemfavorite_fields_createTime];
    PaperItemFavorite *favorite;
    FMResultSet *rs = [_db executeQuery:query_sql,subjectCode,itemCode];
    while ([rs next]) {
        favorite = [self createFavorite:rs];
        break;
    }
    [rs close];
    return favorite;
}
#pragma mark 根据科目代码和试题ID是否收藏
-(BOOL)existFavoriteWithSubjectCode:(NSString *)subjectCode ItemCode:(NSString *)itemCode{
    if(!_db || !subjectCode || subjectCode.length == 0 || !itemCode || itemCode.length == 0) return NO;
    if(![_db tableExists:__k_paperitemfavoritedao_tableName]) return NO;
    NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ? and %@ = ? and %@ = ?",
                           __k_paperitemfavoritedao_tableName,
                           __k_paperitemfavorite_fields_subjectCode,
                           __k_paperitemfavorite_fields_itemCode,
                           __k_paperitemfavorite_fields_status];
    return [_db intForQuery:query_sql,subjectCode,itemCode,[NSNumber numberWithBool:YES]] > 0;
}
//创建收藏数据
-(PaperItemFavorite *)createFavorite:(FMResultSet *)rs{
    if(!rs) return nil;
    PaperItemFavorite *favorite = [[PaperItemFavorite alloc] init];
    favorite.code = [rs stringForColumn:__k_paperitemfavorite_fields_code];
    favorite.subjectCode = [rs stringForColumn:__k_paperitemfavorite_fields_subjectCode];
    favorite.itemCode = [rs stringForColumn:__k_paperitemfavorite_fields_itemCode];
    favorite.itemType = [NSNumber numberWithInt:[rs intForColumn:__k_paperitemfavorite_fields_itemType]];
    favorite.itemContent = [rs stringForColumn:__k_paperitemfavorite_fields_itemContent];
    favorite.remarks = [rs stringForColumn:__k_paperitemfavorite_fields_remarks];
    favorite.status = [NSNumber numberWithInt:[rs intForColumn:__k_paperitemfavorite_fields_status]];
    
    NSString *strCreateTime = [rs stringForColumn:__k_paperitemfavorite_fields_createTime];
    if(strCreateTime && strCreateTime.length > 0){
        favorite.createTime = [strCreateTime toDateWithFormat:nil];
    }
    favorite.sync = [NSNumber numberWithInt:[rs intForColumn:__k_paperitemfavorite_fields_sync]];
    
    //解密试题内容
    favorite.itemContent = [self decryptPaperContentWithEncrypt:favorite.itemContent Password:favorite.itemCode];
    
    return favorite;
}
//加密试题内容
-(NSString *)encryptItemContent:(NSString *)content Password:(NSString *)pwd{
    if(!content || content.length == 0 || !pwd || pwd.length == 0) return nil;
    if([content hasPrefix:__k_paperitemfavoritedao_encryptprefix]){//密文数据
        return content;
    }
    return [NSString stringWithFormat:@"%@%@",
            __k_paperitemfavoritedao_encryptprefix,
            [AESCrypt encryptFromString:content password:pwd]];
}
//解密试卷内容
-(NSString *)decryptPaperContentWithEncrypt:(NSString *)encryptContent Password:(NSString *)pwd{
    if(!encryptContent || !pwd || pwd.length == 0) return nil;
    if(encryptContent.length == 0) return encryptContent;
    if(![encryptContent hasPrefix:__k_paperitemfavoritedao_encryptprefix]){//未加密数据
        return encryptContent;
    }
    NSString *content = [encryptContent substringFromIndex:(__k_paperitemfavoritedao_encryptprefix.length)];
    return [AESCrypt decryptFromString:content password:pwd];
}

#pragma mark 更新收藏数据
-(BOOL)updateFavorite:(PaperItemFavorite *__autoreleasing *)favorite{
    if(!_db || !(*favorite) || ![_db tableExists:__k_paperitemfavoritedao_tableName])return NO;
    BOOL isExists = NO;
    if((*favorite).code && (*favorite).code.length > 0){
        NSString *query_sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = ?",
                     __k_paperitemfavoritedao_tableName,__k_paperitemfavorite_fields_code];
        isExists = [_db intForQuery:query_sql,(*favorite).code] > 0;
    }
    (*favorite).sync = [NSNumber numberWithBool:NO];
    (*favorite).status = [NSNumber numberWithBool:YES];
    if(!(*favorite).remarks || (*favorite).remarks.length == 0){
        (*favorite).remarks = @"收藏";
    }
    //加密试题内容
    NSString *encryptItemContent = [self encryptItemContent:(*favorite).itemContent Password:(*favorite).itemCode];
    
    if(isExists){//更新数据
        NSString *update_sql = [NSString stringWithFormat:@"update %@ set %@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ?,%@ = ? where %@ = ?",
                                __k_paperitemfavoritedao_tableName,
                                
                                __k_paperitemfavorite_fields_subjectCode,
                                __k_paperitemfavorite_fields_itemCode,
                                __k_paperitemfavorite_fields_itemType,
                                __k_paperitemfavorite_fields_itemContent,
                                __k_paperitemfavorite_fields_remarks,
                                //__k_paperitemfavorite_fields_createTime,
                                __k_paperitemfavorite_fields_status,
                                __k_paperitemfavorite_fields_sync,
                                
                                __k_paperitemfavorite_fields_code];
        return [_db executeUpdate:update_sql,
                (*favorite).subjectCode,
                (*favorite).itemCode,
                (*favorite).itemType,
                encryptItemContent,
                (*favorite).remarks,
                (*favorite).status,
                (*favorite).sync,
                (*favorite).code];
    }else{//新增数据
        (*favorite).code = [NSUUID UUID].UUIDString;
        (*favorite).createTime = [NSDate currentLocalTime];
        NSString *insert_sql = [NSString stringWithFormat:@"insert into %@(%@,%@,%@,%@,%@,%@,%@,%@,%@) values(?,?,?,?,?,?,?,?,?)",
                                __k_paperitemfavoritedao_tableName,
                                
                                __k_paperitemfavorite_fields_code,
                                __k_paperitemfavorite_fields_subjectCode,
                                __k_paperitemfavorite_fields_itemCode,
                                __k_paperitemfavorite_fields_itemType,
                                __k_paperitemfavorite_fields_itemContent,
                                __k_paperitemfavorite_fields_remarks,
                                __k_paperitemfavorite_fields_createTime,
                                __k_paperitemfavorite_fields_status,
                                __k_paperitemfavorite_fields_sync];
        
        return [_db executeUpdate:insert_sql,
                (*favorite).code,
                (*favorite).subjectCode,
                (*favorite).itemCode,
                (*favorite).itemType,
                encryptItemContent,
                (*favorite).remarks,
                [NSString stringFromDate:(*favorite).createTime],
                (*favorite).status,
                (*favorite).sync];
    }
}
#pragma mark 删除收藏
-(BOOL)removeFavorite:(NSString *)favoriteCode{
    if(!_db || !favoriteCode || favoriteCode.length == 0 || ![_db tableExists:__k_paperitemfavoritedao_tableName])return NO;
    NSString *update_sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?",
                            __k_paperitemfavoritedao_tableName,
                            
                            __k_paperitemfavorite_fields_status,
                            __k_paperitemfavorite_fields_code];
    return [_db executeUpdate:update_sql,update_sql,[NSNumber numberWithBool:NO],favoriteCode];
}
#pragma mark 删除收藏
-(BOOL)removeFavoriteWithItemCode:(NSString *)itemCode{
    if(!_db || !itemCode || itemCode.length == 0 || ![_db tableExists:__k_paperitemfavoritedao_tableName]) return NO;
    NSString *update_sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?",
                            __k_paperitemfavoritedao_tableName,
                            
                            __k_paperitemfavorite_fields_status,
                            __k_paperitemfavorite_fields_itemCode];
    return [_db executeUpdate:update_sql,[NSNumber numberWithBool:NO], itemCode];
}
#pragma mark 删除收藏
-(BOOL)removeFavoriteWithSubjectCode:(NSString *)subjectCode ItemCode:(NSString *)itemCode{
    if(!_db || !subjectCode || subjectCode.length == 0 || !itemCode || itemCode.length == 0) return NO;
    if(![_db tableExists:__k_paperitemfavoritedao_tableName]) return NO;
    NSString *update_sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ? and %@ = ?",
                            __k_paperitemfavoritedao_tableName,
                            __k_paperitemfavorite_fields_status,
                            __k_paperitemfavorite_fields_subjectCode,
                            __k_paperitemfavorite_fields_itemCode];
    return [_db executeUpdate:update_sql,[NSNumber numberWithBool:NO], subjectCode,itemCode];
}

#pragma mark 加载需同步的数据集合
-(NSArray *)loadSyncFavorites{
    if(!_db || ![_db tableExists:__k_paperitemfavoritedao_tableName]) return nil;
    NSString *query_sql = [NSString stringWithFormat:@"select * from %@ where %@ = ? order by %@",
                           __k_paperitemfavoritedao_tableName,
                           __k_paperitemfavorite_fields_sync,
                           __k_paperitemfavorite_fields_createTime];
    NSMutableArray *arrays = [NSMutableArray array];
    FMResultSet *rs = [_db executeQuery:query_sql,[NSNumber numberWithBool:NO]];
    while ([rs next]) {
        PaperItemFavorite *favorite = [self createFavorite:rs];
        if(favorite && favorite.code && favorite.code.length > 0){
            [arrays addObject:[favorite serializeJSON]];
        }
    }
    [rs close];
    return arrays;
}
#pragma mark 更新同步标示数据
-(void)updateSyncFlagWithIgnoreFavorites:(NSArray *)ignores{
    if(!_db || ![_db tableExists:__k_paperitemfavoritedao_tableName]) return;
    NSString *update_sql;
    if(ignores && ignores.count > 0){
        NSMutableString *ignoreCodes = [NSMutableString string];
        for(NSString *str in ignores){
            if(!str || str.length == 0) continue;
            if(ignoreCodes.length > 0){
                [ignoreCodes appendString:@","];
            }
            [ignoreCodes appendFormat:@"'%@'",str];
        }
        update_sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ? and %@ not in (%@)",
                      __k_paperitemfavoritedao_tableName,
                      __k_paperitemfavorite_fields_sync,
                      __k_paperitemfavorite_fields_sync,
                      __k_paperitemfavorite_fields_code,ignoreCodes];
    }else{
        update_sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?",
                      __k_paperitemfavoritedao_tableName,
                      __k_paperitemfavorite_fields_sync,
                      __k_paperitemfavorite_fields_sync];
        
    }
    //执行标示更新
    [_db executeUpdate:update_sql,[NSNumber numberWithBool:YES],[NSNumber numberWithBool:NO]];
    //执行物理删除数据
    NSString *delete_sql = [NSString stringWithFormat:@"delete from %@ where %@ = ? and %@ = 0",
                            __k_paperitemfavoritedao_tableName,
                            __k_paperitemfavorite_fields_sync,
                            __k_paperitemfavorite_fields_status];
    [_db executeUpdate:delete_sql,[NSNumber numberWithBool:YES]];
}
@end
