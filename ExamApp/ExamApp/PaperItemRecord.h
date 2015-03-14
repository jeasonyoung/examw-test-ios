//
//  PaperItemRecord.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"

//做题记录字段名称
#define __k_paperitemrecord_fields_code @"id"//做题记录ID
#define __k_paperitemrecord_fields_paperRecordCode @"paperRecordId"//所属试卷记录ID。
#define __k_paperitemrecord_fields_structureCode @"structureId"//所属试卷结构ID
#define __k_paperitemrecord_fields_itemCode @"itemId"//所属试卷ID
#define __k_paperitemrecord_fields_itemContent @"content"//试题内容JSON
#define __k_paperitemrecord_fields_answer @"answer"//用户答案
#define __k_paperitemrecord_fields_status @"status"//状态
#define __k_paperitemrecord_fields_score @"score"//得分
#define __k_paperitemrecord_fields_useTimes @"useTimes"//用时
#define __k_paperitemrecord_fields_createTime @"createTime"//创建时间
#define __k_paperitemrecord_fields_lastTime @"lastTime"//最后修改时间
#define __k_paperitemrecord_fields_sync @"sync"//同步标示

//做题记录
@interface PaperItemRecord : NSObject<JSONSerialize>
//做题记录ID
@property(nonatomic,copy)NSString *code;
//所属试卷记录ID
@property(nonatomic,copy)NSString *paperRecordCode;
//所属试卷结构ID
@property(nonatomic,copy)NSString *structureCode;
//所属试题ID
@property(nonatomic,copy)NSString *itemCode;
//所属试题内容(JSON)
@property(nonatomic,copy)NSString *itemContent;
//用户答案
@property(nonatomic,copy)NSString *answer;
//状态(0-错误，1-正确)
@property(nonatomic,assign)NSNumber *status;
//得分
@property(nonatomic,copy)NSNumber *score;
//用时(秒)
@property(nonatomic,assign)NSNumber *useTimes;
//创建时间
@property(nonatomic,copy)NSDate *createTime;
//最后修改时间
@property(nonatomic,copy)NSDate *lastTime;
//同步标示(0-未同步，1-已同步)
@property(nonatomic,assign)NSNumber *sync;
@end
