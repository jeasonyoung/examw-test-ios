//
//  AnimationUtils.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//特效工具类
@interface EffectsUtils : NSObject

//添加圆角边框
+(void)addBoundsRadiusWithView:(UIView *)view
                  CornerRadius:(CGFloat)radius
                   BorderColor:(UIColor *)borderColor
                   BorderWidth:(CGFloat)borderWidth
               BackgroundColor:(UIColor *)bgColor;
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

//三维翻转动画
+(void)animationMediaTimingEaseInEaseOutWithView:(UIView *)view delegate:(id)delegate;
@end
