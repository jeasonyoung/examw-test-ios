//
//  UIViewUtils.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//界面视图工具类
@interface UIViewUtils : NSObject
//添加圆角边框
+(void)addBoundsRadiusWithView:(UIView *)view
                   BorderColor:(UIColor *)borderColor
               BackgroundColor:(UIColor *)bgColor;
//添加边框
+(void)addBorderWithView:(UIView *)view
             BorderColor:(UIColor *)borderColor
         BackgroundColor:(UIColor *)bgColor;
//添加边框重载
+(void)addBorderWithView:(UIView *)view
             BorderColor:(UIColor *)borderColor
             BorderWidth:(CGFloat)borderWith
         BackgroundColor:(UIColor *)bgColor;
@end
