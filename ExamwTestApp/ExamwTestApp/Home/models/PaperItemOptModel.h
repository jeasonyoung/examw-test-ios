//
//  PaperItemOptModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaperItemTitleModel.h"
//试题选项数据模型
@interface PaperItemOptModel : PaperItemTitleModel

//是否显示答案
@property(nonatomic,assign)BOOL display;

//我的答案
@property(nonatomic,copy)NSString *myAnswers;

//正确答案
@property(nonatomic,copy)NSString *rightAnswers;

@end
