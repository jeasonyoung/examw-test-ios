//
//  AnswerCardModel+MakeObjects.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnswerCardModel.h"

//答题卡数据模型扩展
@interface AnswerCardModel (MakeObjects)
//加载试题状态
-(void)loadItemStatusWithObjs:(NSArray *)objs;
@end
