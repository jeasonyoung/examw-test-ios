//
//  PaperTitleModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

//试卷标题模型
@interface PaperTitleModel : NSObject

//试卷标题
@property(nonatomic,copy)NSString *title;

//科目名称
@property(nonatomic,copy)NSString *subject;

//初始化
-(instancetype)initWithTitle:(NSString *)title andSubject:(NSString *)subject;
@end
