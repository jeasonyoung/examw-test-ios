//
//  MyModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

//我的列表数据模型
@interface MySubjectModel : NSObject
//图标名称
@property(nonatomic,copy)NSString *iconName;
//科目代码
@property(nonatomic,copy)NSString *subjectCode;
//科目名称
@property(nonatomic,copy)NSString *subject;
//统计
@property(nonatomic,assign)NSUInteger total;

//初始化
-(instancetype)initWithIcon:(NSString *)icon;
@end
