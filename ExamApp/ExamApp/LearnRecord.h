//
//  LearnRecord.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/16.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//学习记录数据模型
@interface LearnRecord : NSObject
//学习记录ID
@property(nonatomic,copy)NSString *code;
//所属试卷ID
@property(nonatomic,copy)NSString *paperCode;
//试卷类型名称
@property(nonatomic,copy)NSString *paperTypeName;
//试卷标题
@property(nonatomic,copy)NSString *paperTitle;
//用时(秒)
@property(nonatomic,copy)NSNumber *useTimes;
//得分
@property(nonatomic,copy)NSNumber *score;
//最后做题时间
@property(nonatomic,copy)NSDate *lastTime;
@end
