//
//  WaitFor.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "WaitForAnimation.h"
#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
//启动动画成员变量。
@interface WaitForAnimation(){
    MBProgressHUD *_waitHud;
}
@end
//启动动画实现类。
@implementation WaitForAnimation
#pragma mark 构造函数
-(instancetype)initWithView:(UIView *)view WaitTitle:(NSString *)title{
    if(self = [super init]){
        if(view){
            _waitHud = [[MBProgressHUD alloc] init];
            _waitHud.labelText = title;
            _waitHud.dimBackground = YES;//使背景成黑灰色，让MBProgressHUD成高亮显示
            _waitHud.square =  YES;//设置显示框的高度和宽度一样
            //_waitHud.mode = MBProgressHUDModeAnnularDeterminate;
            [view addSubview:_waitHud];
        }
    }
    return self;
}
#pragma mark 显示动画
-(void)show{
    if(_waitHud){
        [_waitHud show:YES];
    }
}
#pragma mark 隐藏动画
-(void)hide{
    if(_waitHud){
        [_waitHud hide:YES];
    }
}
#pragma mark 执行动画
-(void)animationWithBlock:(void (^)())block{
    //显示动画
    [self show];
    //执行块
    block();
    //隐藏动画
    [self hide];
}
#pragma mark 静态处理
+(void)animationWithView:(UIView *)view WaitTitle:(NSString *)title Block:(void (^)())block{
    WaitForAnimation *waitFor = [[WaitForAnimation alloc] initWithView:view WaitTitle:title];
    [waitFor animationWithBlock:^{//执行块
        block();
    }];
}
@end
