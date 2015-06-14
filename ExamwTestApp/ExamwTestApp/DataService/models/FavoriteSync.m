//
//  FavoriteSync.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FavoriteSync.h"

#define __kFavoriteSync_keys_Id @"id"//1.收藏ID
#define __kFavoriteSync_keys_subjectId @"subjectId"//2.所属科目ID
#define __kFavoriteSync_keys_itemId @"itemId"//3.所属试题ID
#define __kFavoriteSync_keys_itemType @"itemType"//4.所属题型
#define __kFavoriteSync_keys_content @"content"//5.试题内容JSON
#define __kFavoriteSync_keys_remarks @"remarks"//6.备注
#define __kFavoriteSync_keys_status @"status"//7.状态
#define __kFavoriteSync_keys_createTime @"createTime"//8.收藏时间

//收藏数据同步实现
@implementation FavoriteSync

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        NSArray *keys = dict.allKeys;
        //1.收藏ID
        if([keys containsObject:__kFavoriteSync_keys_Id]){
            id value = [dict objectForKey:__kFavoriteSync_keys_Id];
            _Id = (value == [NSNull null] ? @"" : value);
        }
        //2.所属科目ID
        if([keys containsObject:__kFavoriteSync_keys_subjectId]){
            id value = [dict objectForKey:__kFavoriteSync_keys_subjectId];
            _subjectId = (value == [NSNull null] ? @"" : value);
        }
        //3.所属试题ID
        if([keys containsObject:__kFavoriteSync_keys_itemId]){
            id value = [dict objectForKey:__kFavoriteSync_keys_itemId];
            _itemId = (value == [NSNull null] ? @"" : value);
        }
        //4.所属题型
        if([keys containsObject:__kFavoriteSync_keys_itemType]){
            id value = [dict objectForKey:__kFavoriteSync_keys_itemType];
            _itemType = (value == [NSNull null] ? 0 : [value integerValue]);
        }
        //5.试题内容JSON
        if([keys containsObject:__kFavoriteSync_keys_content]){
            id value = [dict objectForKey:__kFavoriteSync_keys_content];
            _content = (value == [NSNull null] ? @"" : value);
        }
        //6.备注
        if([keys containsObject:__kFavoriteSync_keys_remarks]){
            id value = [dict objectForKey:__kFavoriteSync_keys_remarks];
            _remarks = (value == [NSNull null] ? @"" : value);
        }
        //7.状态
        if([keys containsObject:__kFavoriteSync_keys_status]){
            id value = [dict objectForKey:__kFavoriteSync_keys_status];
            _status = (value == [NSNull null] ? 0 : [value integerValue]);
        }
        //8.收藏时间
        if([keys containsObject:__kFavoriteSync_keys_createTime]){
            id value = [dict objectForKey:__kFavoriteSync_keys_createTime];
            _createTime = (value == [NSNull null] ? [NSDate date] : value);
        }
    }
    return self;
}

#pragma mark 序列化
-(NSDictionary *)serialize{
    NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return @{__kFavoriteSync_keys_Id : (_Id ? _Id : @""),
             __kFavoriteSync_keys_subjectId : (_subjectId ? _subjectId : @""),
             __kFavoriteSync_keys_itemId : (_itemId ? _itemId : @""),
             __kFavoriteSync_keys_itemType : [NSNumber numberWithInteger:_itemType],
             __kFavoriteSync_keys_content : (_content ? _content : @""),
             __kFavoriteSync_keys_remarks : (_remarks ? _remarks : @""),
             __kFavoriteSync_keys_status : [NSNumber numberWithInteger:_status],
             __kFavoriteSync_keys_createTime : [dtFormatter stringFromDate:(_createTime ? _createTime : [NSDate date])]};
}

@end
