//
//  AboutData.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//关于应用数据(图标尺寸:58*58 87*87 80*80 120*120 180*180)
@interface AboutData : NSObject
//标题
@property(nonatomic,copy)NSString *title;
//子标题
@property(nonatomic,copy)NSString *subTitle;
//图标地址
@property(nonatomic,copy)NSString *icon;
//版本
@property(nonatomic,copy)NSNumber *version;
//官网
@property(nonatomic,copy)NSString *website;
//联系电话
@property(nonatomic,copy)NSString *tel;
//版权信息
@property(nonatomic,copy)NSString *copyright;

//从字典中加载数据
+(instancetype)aboutWithDict:(NSDictionary *)dict;
//加载数据
+(instancetype)loadAboutData;
@end
