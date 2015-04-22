//
//  UIViewUtils.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UIViewUtils.h"

#define __kUIViewUtils_borderWith 0.8//边框宽度
#define __kUIViewUtils_cornerRadius 8.5//圆角弧度
//界面视图工具类实现
@implementation UIViewUtils
#pragma mark 添加边框圆角和背景色
+(void)addBoundsRadiusWithView:(UIView *)view
                  CornerRadius:(CGFloat)radius
                   BorderColor:(UIColor *)borderColor
                   BorderWidth:(CGFloat)borderWidth
               BackgroundColor:(UIColor *)bgColor{
    if(view){
        //设置边框圆角
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = radius;
        if(borderColor){//边框颜色
            view.layer.borderWidth = borderWidth;
            view.layer.borderColor = [borderColor CGColor];
        }
        if(bgColor){//添加背景色
            view.backgroundColor = bgColor;
        }
    }
}
#pragma mark 添加边框圆角和背景色
+(void)addBoundsRadiusWithView:(UIView *)view
                   BorderColor:(UIColor *)borderColor
               BackgroundColor:(UIColor *)bgColor{
    [self addBoundsRadiusWithView:view
                     CornerRadius:__kUIViewUtils_cornerRadius
                      BorderColor:borderColor
                      BorderWidth:__kUIViewUtils_borderWith
                  BackgroundColor:bgColor];
}
#pragma mark 添加边框
+(void)addBorderWithView:(UIView *)view
             BorderColor:(UIColor *)borderColor
             BorderWidth:(CGFloat)borderWith
         BackgroundColor:(UIColor *)bgColor{
    if(view){
        if(borderColor){//边框颜色
            view.layer.borderWidth = borderWith;
            view.layer.borderColor = [borderColor CGColor];
        }
        if(bgColor){//添加背景色
            view.backgroundColor = bgColor;
        }
    }
}
#pragma mark 添加边框
+(void)addBorderWithView:(UIView *)view
             BorderColor:(UIColor *)borderColor
         BackgroundColor:(UIColor *)bgColor{
    [self addBorderWithView:view BorderColor:borderColor BorderWidth:__kUIViewUtils_borderWith BackgroundColor:bgColor];
}
@end