//
//  TitleModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

//标题数据模型
@interface TitleModel : NSObject
//标题
@property(nonatomic,copy)NSString *title;
//初始化
-(instancetype)initWithTitle:(NSString *)title;
@end
