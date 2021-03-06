//
//  ETNavigationController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ETNavigationController.h"
#import "UINavigationController+Animation.h"
#import "UIViewController+Animation.h"

#import "ItemViewController.h"
//自定义向导控制器成员变量
@interface ETNavigationController (){

}
@end
//自定义向导控制器实现类
@implementation ETNavigationController
#pragma mark 重载push拦截所有push进来的子控制器
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if(!viewController)return;
//    //如果现在push的不是栈顶的控制器，那么就隐藏tabber工具条
//    if(self.viewControllers.count > 0 && ![viewController isKindOfClass:[ItemViewController class]]){
//        viewController.hidesBottomBarWhenPushed = YES;
//    }
    if(!animated && viewController.enableTransitionAnimation){
        CATransition *animation = [self createTransitionAnimation];
        //设置转场动画
        [self.view.layer addAnimation:animation forKey:nil];
    }
    NSLog(@"pushViewController => %d <=> %@",viewController.enableTransitionAnimation,viewController);
    //调用父类方法
    [super pushViewController:viewController animated:animated];
}
@end
