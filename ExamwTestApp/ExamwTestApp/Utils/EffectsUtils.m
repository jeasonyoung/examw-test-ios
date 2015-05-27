//
//  AnimationUtils.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "EffectsUtils.h"

#define __kEffectsUtils_borderWith 0.6//边框宽度
#define __kEffectsUtils_cornerRadius 8.5//圆角弧度

//动画工具类实现
@implementation EffectsUtils

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
                     CornerRadius:__kEffectsUtils_cornerRadius
                      BorderColor:borderColor
                      BorderWidth:__kEffectsUtils_borderWith
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
    [self addBorderWithView:view BorderColor:borderColor BorderWidth:__kEffectsUtils_borderWith BackgroundColor:bgColor];
}

#pragma mark 立方体动画
+(void)animationCubeWithView:(UIView *)view delegate:(id)delegate{
    if(!view) return;
    NSLog(@"设置[%@]立方体动画...", view);
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"cube";
    transition.subtype = kCATransitionFromRight;
    transition.delegate = delegate;
    
    [view.layer addAnimation:transition forKey:nil];
}

#pragma mark Push转场动画
+(void)animationPushWithView:(UIView *)view delegate:(id)delegate{
    if(!view) return;
    NSLog(@"设置[%@]Push动画...", view);
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.delegate = delegate;
    
    [view.layer addAnimation:transition forKey:nil];
}
@end
