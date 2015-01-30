//
//  ETNavigationController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ETNavigationController.h"
#import "UINavigationController+Animation.h"
//自定义向导控制器成员变量
@interface ETNavigationController ()

@end
//自定义向导控制器实现类
@implementation ETNavigationController
#pragma mark 重载push拦截所有push进来的子控制器
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    //如果现在push的不是栈顶的控制器，那么就隐藏tabber工具条
    if(self.viewControllers.count > 0){
        viewController.hidesBottomBarWhenPushed = YES;
    }
    if(!animated){
        //设置动画效果
        CATransition *animation = [self createTransitionAnimation];
        if(animation != nil){
            //设置转场动画
            [self.view.layer addAnimation:animation forKey:nil];
        }
    }
    //调用父类方法
    [super pushViewController:viewController animated:animated];
}
@end
