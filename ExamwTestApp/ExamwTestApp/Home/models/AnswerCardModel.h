//
//  AnswerCardModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//答题卡试题数据模型
@interface AnswerCardModel : NSObject

//试题序号
@property(nonatomic,assign,readonly)NSUInteger order;
//状态(0-未做,1-做对,2-做错)
@property(nonatomic,assign)NSUInteger status;
//是否显示答案
@property(nonatomic,assign,readonly)BOOL displayAnswer;
//初始化
-(instancetype)initWithOrder:(NSUInteger)order status:(NSUInteger)status displayAnswer:(BOOL)display;
@end
