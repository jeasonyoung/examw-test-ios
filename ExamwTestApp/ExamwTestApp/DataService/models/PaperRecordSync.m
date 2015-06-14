//
//  PaperRecordSync.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperRecordSync.h"

#define __kPaperRecordSync_keys_id @"id"//试卷记录ID
#define __kPaperRecordSync_keys_paperId @"paperId"//所属试卷ID
#define __kPaperRecordSync_keys_status @"status"//做题状态
#define __kPaperRecordSync_keys_rights @"rights"//做对的试题数
#define __kPaperRecordSync_keys_useTimes @"useTimes"//做题用时
#define __kPaperRecordSync_keys_score @"score"//得分
#define __kPaperRecordSync_keys_createTime @"createTime"//创建时间
#define __kPaperRecordSync_keys_lastTime @"lastTime"//最后修改时间
//试卷做题记录上传同步实现
@implementation PaperRecordSync

#pragma mark 初始化
-(instancetype)initWithDict:(NSDictionary *)dict{
    if((self = [super init]) && dict && dict.count > 0){
        NSArray *keys = dict.allKeys;
        //1.试卷记录ID
        if([keys containsObject:__kPaperRecordSync_keys_id]){
            id value = [dict objectForKey:__kPaperRecordSync_keys_id];
            _Id = (value == [NSNull null] ? @"" : value);
        }
        //2.所属试卷ID
        if([keys containsObject:__kPaperRecordSync_keys_paperId]){
            id value = [dict objectForKey:__kPaperRecordSync_keys_paperId];
            _paperId = (value == [NSNull null] ? @"" : value);
        }
        //3.做题状态
        if([keys containsObject:__kPaperRecordSync_keys_status]){
            id value = [dict objectForKey:__kPaperRecordSync_keys_status];
            _status = (value == [NSNull null] ? 0 : [value integerValue]);
        }
        //4.做对的试题数
        if([keys containsObject:__kPaperRecordSync_keys_rights]){
            id value = [dict objectForKey:__kPaperRecordSync_keys_rights];
            _rights = (value == [NSNull null] ? 0 : [value integerValue]);
        }
        //5.做题用时
        if([keys containsObject:__kPaperRecordSync_keys_useTimes]){
            id value = [dict objectForKey:__kPaperRecordSync_keys_useTimes];
            _useTimes = (value == [NSNull null] ? 0 : [value integerValue]);
        }
        //6.得分
        if([keys containsObject:__kPaperRecordSync_keys_score]){
            id value = [dict objectForKey:__kPaperRecordSync_keys_score];
            _score = (value == [NSNull null] ? 0 : [value doubleValue]);
        }
        //7.创建时间
        if([keys containsObject:__kPaperRecordSync_keys_createTime]){
            id value = [dict objectForKey:__kPaperRecordSync_keys_createTime];
            _createTime = (value == [NSNull null] ? [NSDate date] : value);
        }
        //8.最后修改时间
        if([keys containsObject:__kPaperRecordSync_keys_lastTime]){
            id value = [dict objectForKey:__kPaperRecordSync_keys_lastTime];
            _lastTime = (value == [NSNull null] ? [NSDate date] : value);
        }
    }
    return self;
}

#pragma mark 序列化
-(NSDictionary *)serialize{
    NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setDateFormat:@"yyyyy-MM-dd HH:mm:ss"];
    
    return @{__kPaperRecordSync_keys_id : (_Id ? _Id : @""),
             __kPaperRecordSync_keys_paperId : (_paperId ? _paperId : @""),
             __kPaperRecordSync_keys_status : [NSNumber numberWithInteger:_status],
             __kPaperRecordSync_keys_rights : [NSNumber numberWithInteger:_rights],
             __kPaperRecordSync_keys_useTimes : [NSNumber numberWithInteger:_useTimes],
             __kPaperRecordSync_keys_score : [NSNumber numberWithDouble:_score],
             __kPaperRecordSync_keys_createTime :[dtFormatter stringFromDate:(_createTime ? _createTime : [NSDate date])],
             __kPaperRecordSync_keys_lastTime : [dtFormatter stringFromDate:(_lastTime ? _lastTime : [NSDate date])]};
}

@end
