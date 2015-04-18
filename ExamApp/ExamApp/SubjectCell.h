//
//  FavoriteSubject.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/17.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//科目的TableView的Cell数据模型
@interface SubjectCell : NSObject
//科目代码
@property(nonatomic,copy)NSString *code;
//科目名称
@property(nonatomic,copy)NSString *name;
//统计数据
@property(nonatomic,copy)NSNumber *total;
@end
