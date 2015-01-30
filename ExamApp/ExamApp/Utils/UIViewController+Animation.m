//
//  UIViewController+Animation.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UIViewController+Animation.h"
//视图控制器动画分类实现类
@implementation UIViewController (Animation)
BOOL _enableTransitionAnimation = YES;
#pragma mark 获取是否启用转场动画
-(BOOL)enableTransitionAnimation{
    return _enableTransitionAnimation;
}
#pragma mark 设置是否启用转场动画
-(void)setEnableTransitionAnimation:(BOOL)enableTransitionAnimation{
    _enableTransitionAnimation = enableTransitionAnimation;
}
@end
