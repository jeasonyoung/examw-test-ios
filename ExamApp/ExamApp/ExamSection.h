//
//  ExamSection.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/17.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//考试TableViewCell的Section数据
@interface ExamSection : NSObject
//考试代码
@property(nonatomic,copy)NSString *code;
//考试名称
@property(nonatomic,copy)NSString *name;
@end
