//
//  SettingData.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//设置数据
@interface SettingData : NSObject
//主键
@property(nonatomic,copy)NSString *key;
//标题
@property(nonatomic,copy)NSString *title;
//类型
@property(nonatomic,copy)NSString *type;
//数据
@property(nonatomic,copy)NSString *data;

//初始化创建对象
+(instancetype)settingDataWithDict:(NSDictionary *)dict;
//加载对象集合
+(NSArray *)loadSettingData;
@end
