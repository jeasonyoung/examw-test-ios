//
//  AppSettings.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//应用全局设置
@interface AppSettings : NSObject
//考试类别ID
@property(nonatomic,copy,readonly)NSString *categoryId;
//考试ID
@property(nonatomic,copy,readonly)NSString *examId;
//考试名称
@property(nonatomic,copy,readonly)NSString *examName;
//考试科目ID
@property(nonatomic,copy,readonly)NSString *subjectId;
//考试科目名称
@property(nonatomic,copy,readonly)NSString *subjectName;
//考试产品ID
@property(nonatomic,copy,readonly)NSString *productId;
//考试产品名称
@property(nonatomic,copy,readonly)NSString *productName;
//从本地用户配置中加载设置
+(instancetype)settingsDefaults;
//设置考试类别ID
-(void)setCategory:(NSString *)categoryId;
//设置考试ID和名称
-(void)setExamWithId:(NSString *)examId andName:(NSString *)examName;
//设置科目ID和名称
-(void)setSubjectWithId:(NSString *)subjectId andName:(NSString *)subjectName;
//设置产品ID和名称
-(void)setProductWithId:(NSString *)productId andName:(NSString *)productName;
//校验是否有效
-(BOOL)verification;
//保存到本地用户配置中
-(BOOL)saveToDefaults;
@end
