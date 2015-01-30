//
//  UINavigationController+Animation.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UINavigationController+Animation.h"
//转场动画分类实现
@implementation UINavigationController (Animation)
#pragma mark 创建转场动画
-(CATransition *)createTransitionAnimation{
    //设置动画效果
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.5;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromRight;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animation;
}
@end
