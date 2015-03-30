//
//  HomeData.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//主页九宫格数据
@interface HomeData : NSObject
//标题
@property(nonatomic,copy)NSString *title;
//值
@property(nonatomic,copy)NSString *value;
//显示图片
@property(nonatomic,copy)NSString *normalImage;
//选中时的图片
@property(nonatomic,copy)NSString *selectedImage;
//创建对象
+(instancetype)homeDataWithDict:(NSDictionary *)dict;
//加载对象集合
+(NSArray *)loadHomeData;
//加载考试日期
+(NSDate *)loadExamDate;
//更新考试日期
+(void)updateExamDate:(NSDate *)date;
@end