//
//  PaperRecord.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"

//字段描述
#define __k_paperrecord_fields_code @"id"//试卷记录ID
#define __k_paperrecord_fields_paperCode @"paperId"//所属试卷ID
#define __k_paperrecord_fields_status @"status"//做题状态
#define __k_paperrecord_fields_score @"score"//得分
#define __k_paperrecord_fields_rights @"rights"//做对的题目数
#define __k_paperrecord_fields_useTimes @"useTimes"//做题用时
#define __k_paperrecord_fields_createTime @"createTime"//创建时间
#define __k_paperrecord_fields_lastTime @"lastTime"//最后修改时间
#define __k_paperrecord_fields_sync @"sync"//同步标示
//试卷记录
@interface PaperRecord : NSObject<JSONSerialize>
//试卷记录ID
@property(nonatomic,copy)NSString *code;
//所属试卷ID
@property(nonatomic,copy)NSString *paperCode;
//状态(0-未做完，1-已做完)
@property(nonatomic,assign)NSNumber *status;
//得分
@property(nonatomic,copy)NSNumber *score;
//做对的题目个数
@property(nonatomic,assign)NSNumber *rights;
//用时(秒)
@property(nonatomic,assign)NSNumber *useTimes;
//创建时间
@property(nonatomic,copy)NSDate *createTime;
//最后修改时间
@property(nonatomic,copy)NSDate *lastTime;
//同步标示(0-未同步,1-已同步)
@property(nonatomic,assign)NSNumber *sync;
@end