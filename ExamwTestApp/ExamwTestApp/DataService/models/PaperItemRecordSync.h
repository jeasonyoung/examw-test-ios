//
//  PaperItemRecordSync.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//试题记录同步数据
@interface PaperItemRecordSync : NSObject<JSONSerialize>
//1.做题记录ID
@property(nonatomic,copy)NSString *Id;
//2.所属试卷记录ID
@property(nonatomic,copy)NSString *paperRecordId;
//3.所属试卷结构ID
@property(nonatomic,copy)NSString *structureId;
//4.所属试题ID
@property(nonatomic,copy)NSString *itemId;
//5.试题内容JSON
@property(nonatomic,copy)NSString *content;
//6.用户答案
@property(nonatomic,copy)NSString *answer;
//7.做题状态
@property(nonatomic,assign)NSInteger status;
//8.得分
@property(nonatomic,assign)double score;
//9.做题用时
@property(nonatomic,assign)NSInteger useTimes;
//10.创建时间
@property(nonatomic,copy)NSDate *createTime;
//11.最后修改时间
@property(nonatomic,copy)NSDate *lastTime;
@end
