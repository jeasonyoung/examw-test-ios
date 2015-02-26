//
//  WaitFor.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIView;
//等待动画
@interface WaitForAnimation : NSObject
//初始化
-(instancetype)initWithView:(UIView *)view WaitTitle:(NSString *)title;
//显示动画
-(void)show;
//隐藏动画
-(void)hide;
//执行动画
-(void)animationWithBlock:(void(^)())block;
//等待动画
+(void)animationWithView:(UIView *)view WaitTitle:(NSString *)title Block:(void(^)())block;
@end