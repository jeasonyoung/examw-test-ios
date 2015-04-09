//
//  ETAlert.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//弹出框封装类
@interface ETAlert : NSObject
//初始化
-(instancetype)initWithTitle:(NSString *)title Message:(NSString *)msg;
//添加文本输入框
-(void)addTextFieldWithConfigurationHandler:(void(^)(UITextField *textField))handler;
//添加取消按钮
-(void)addCancelActionWithTitle:(NSString *)title Handler:(void(^)(UIAlertAction *action))handler;
//添加确定按钮
-(void)addConfirmActionWithTitle:(NSString *)title Handler:(void(^)(UIAlertAction *action))handler;
//显示
-(void)showWithController:(UIViewController *)controller;
//按钮集合数组
-(NSArray *)actions;
//输入框集合数组
-(NSArray *)textFields;
//显示提示信息
+(void)alertWithTitle:(NSString *)title Message:(NSString *)msg ButtonTitle:(NSString *)btnTitle Controller:(UIViewController *)controller;
@end
