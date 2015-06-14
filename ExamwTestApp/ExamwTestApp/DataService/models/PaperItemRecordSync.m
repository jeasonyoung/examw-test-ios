//
//  PaperItemRecordSync.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemRecordSync.h"

#define __kPaperItemRecordSync_keys_Id @"id"//1.做题记录ID
#define __kPaperItemRecordSync_keys_paperRecordId @"paperRecordId"//2.所属试卷记录ID
#define __kPaperItemRecordSync_keys_structureId @"structureId"//3.所属试卷结构ID
#define __kPaperItemRecordSync_keys_itemId @"itemId"//4.所属试题ID
#define __kPaperItemRecordSync_keys_content @"content"//5.试题内容JSON
#define __kPaperItemRecordSync_keys_answer @"answer"//6.用户答案
#define __kPaperItemRecordSync_keys_status @"status"//7.做题状态
#define __kPaperItemRecordSync_keys_score @"score"//8.得分
#define __kPaperItemRecordSync_keys_useTimes @"useTimes"//9.做题用时
#define __kPaperItemRecordSync_keys_createTime @"createTime"//10.创建时间
#define __kPaperItemRecordSync_keys_lastTime @"lastTime"//11.最后修改时间

//试题记录同步数据实现
@implementation PaperItemRecordSync

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        NSArray *keys = dict.allKeys;
        //1.做题记录ID
        if([keys containsObject:__kPaperItemRecordSync_keys_Id]){
            id value = [dict objectForKey:__kPaperItemRecordSync_keys_Id];
            _Id = (value == [NSNull null] ? @"" : value);
        }
        //2.所属试卷记录ID
        if([keys containsObject:__kPaperItemRecordSync_keys_paperRecordId]){
            id value = [dict objectForKey:__kPaperItemRecordSync_keys_paperRecordId];
            _paperRecordId = (value == [NSNull null] ? @"" : value);
        }
        //3.所属试卷结构ID
        if([keys containsObject:__kPaperItemRecordSync_keys_structureId]){
            id value = [dict objectForKey:__kPaperItemRecordSync_keys_structureId];
            _structureId = (value == [NSNull null] ? @"" : value);
        }
        //4.所属试题ID
        if([keys containsObject:__kPaperItemRecordSync_keys_itemId]){
            id value = [dict objectForKey:__kPaperItemRecordSync_keys_itemId];
            _itemId = (value == [NSNull null] ? @"" : value);
        }
        //5.试题内容JSON
        if([keys containsObject:__kPaperItemRecordSync_keys_content]){
            id value = [dict objectForKey:__kPaperItemRecordSync_keys_content];
            _content = (value == [NSNull null] ? @"" : value);
        }
        //6.用户答案
        if([keys containsObject:__kPaperItemRecordSync_keys_answer]){
            id value = [dict objectForKey:__kPaperItemRecordSync_keys_answer];
            _answer = (value == [NSNull null] ? @"" : value);
        }
        //7.做题状态
        if([keys containsObject:__kPaperItemRecordSync_keys_status]){
            id value = [dict objectForKey:__kPaperItemRecordSync_keys_status];
            _status = (value == [NSNull null] ? 0 : [value integerValue]);
        }
        //8.得分
        if([keys containsObject:__kPaperItemRecordSync_keys_score]){
            id value = [dict objectForKey:__kPaperItemRecordSync_keys_score];
            _score = (value == [NSNull null] ? 0 : [value doubleValue]);
        }
        //9.做题用时
        if([keys containsObject:__kPaperItemRecordSync_keys_useTimes]){
            id value = [dict objectForKey:__kPaperItemRecordSync_keys_useTimes];
            _useTimes = (value == [NSNull null] ? 0 : [value integerValue]);
        }
        //10.创建时间
        if([keys containsObject:__kPaperItemRecordSync_keys_createTime]){
            id value = [dict objectForKey:__kPaperItemRecordSync_keys_createTime];
            _createTime = (value == [NSNull null] ? [NSDate date] : value);
        }
        //11.最后修改时间
        if([keys containsObject:__kPaperItemRecordSync_keys_lastTime]){
            id value = [dict objectForKey:__kPaperItemRecordSync_keys_lastTime];
            _lastTime = (value == [NSNull null] ? [NSDate date] : value);
        }
    }
    return self;
}

#pragma mark 序列化
-(NSDictionary *)serialize{
    NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return @{__kPaperItemRecordSync_keys_Id : (_Id ? _Id : @""),
             __kPaperItemRecordSync_keys_paperRecordId : (_paperRecordId ? _paperRecordId : @""),
             __kPaperItemRecordSync_keys_structureId : (_structureId ? _structureId : @""),
             __kPaperItemRecordSync_keys_itemId : (_itemId ? _itemId : @""),
             __kPaperItemRecordSync_keys_content : (_content ? _content : @""),
             __kPaperItemRecordSync_keys_answer : (_answer ? _answer : @""),
             __kPaperItemRecordSync_keys_status : [NSNumber numberWithInteger:_status],
             __kPaperItemRecordSync_keys_score : [NSNumber numberWithDouble:_score],
             __kPaperItemRecordSync_keys_useTimes : [NSNumber numberWithInteger:_useTimes],
             __kPaperItemRecordSync_keys_createTime :[dtFormatter stringFromDate:(_createTime ? _createTime : [NSDate date])],
             __kPaperItemRecordSync_keys_lastTime:[dtFormatter stringFromDate:(_lastTime ? _lastTime : [NSDate date])]};
}

@end
