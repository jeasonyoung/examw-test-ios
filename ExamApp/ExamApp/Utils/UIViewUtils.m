//
//  UIViewUtils.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UIViewUtils.h"
//界面视图工具类实现
@implementation UIViewUtils
//添加边框圆角和背景设
+(void)addBoundsRadiusWithView:(UIView *)view BorderColor:(UIColor *)borderColor BackgroundColor:(UIColor *)bgColor{
    if(view){
        //设置边框圆角
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 8.5;
        if(borderColor){//边框颜色
            view.layer.borderWidth = 0.8;
            view.layer.borderColor = [borderColor CGColor];
        }
        if(bgColor){//添加背景色
            view.backgroundColor = bgColor;
        }
    }
}
//添加边框
+(void)addBorderWithView:(UIView *)view BorderColor:(UIColor *)borderColor BackgroundColor:(UIColor *)bgColor{
    if(view){
        if(borderColor){//边框颜色
            view.layer.borderWidth = 0.8;
            view.layer.borderColor = [borderColor CGColor];
        }
        if(bgColor){//添加背景色
            view.backgroundColor = bgColor;
        }
    }
}
@end