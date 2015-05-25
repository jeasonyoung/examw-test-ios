//
//  AnimationUtils.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AnimationUtils.h"

//动画工具类实现
@implementation AnimationUtils

#pragma mark 三维翻转动画
+(void)mediaTimingEaseInEaseOutWithView:(UIView *)view delegate:(id)delegate{
    if(!view) return;
    NSLog(@"设置[%@]三维翻转动画...", view);
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"cube";
    transition.subtype = kCATransitionFromRight;
    transition.delegate = delegate;
    
    [view.layer addAnimation:transition forKey:nil];
}

@end
