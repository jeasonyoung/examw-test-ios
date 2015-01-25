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
@property(nonatomic,copy)NSString *normal;
//选中时的图片
@property(nonatomic,copy)NSString *selected;
//创建对象
+(instancetype)homeDataWithDict:(NSDictionary *)dict;
//加载对象集合
+(NSArray *)loadHomeData;
@end