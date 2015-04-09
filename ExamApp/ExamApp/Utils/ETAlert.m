//
//  ETAlert.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ETAlert.h"
//弹出框封装类成员变量
@interface ETAlert(){
    UIAlertController *_alertController;
}
@end
//弹出框封装类实现
@implementation ETAlert
#pragma mark 初始化
-(instancetype)initWithTitle:(NSString *)title Message:(NSString *)msg{
    if(self = [super init]){
        _alertController = [UIAlertController alertControllerWithTitle:title
                                                               message:msg
                                                        preferredStyle:UIAlertControllerStyleAlert];
    }
    return self;
}
#pragma mark 添加文本输入框
-(void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *))handler{
    if(_alertController && handler){
        [_alertController addTextFieldWithConfigurationHandler:handler];
    }
}
#pragma mark 添加取消按钮
-(void)addCancelActionWithTitle:(NSString *)title Handler:(void (^)(UIAlertAction *))handler{
    if(title){
        UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:title
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              if(handler){
                                                                  handler(action);
                                                              }
                                                          }];
        [_alertController addAction:btnCancel];
    }
}
#pragma mark 添加确定按钮
-(void)addConfirmActionWithTitle:(NSString *)title Handler:(void (^)(UIAlertAction *))handler{
    if(title){
        UIAlertAction *btnConfirm = [UIAlertAction actionWithTitle:title
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               if(handler){
                                                                   handler(action);
                                                               }
                                                           }];
        [_alertController addAction:btnConfirm];
    }
}
#pragma mark 获取按钮集合
-(NSArray *)actions{
    return _alertController ? _alertController.actions : nil;
}
#pragma mark 获取输入框集合
-(NSArray *)textFields{
    return _alertController ? _alertController.textFields : nil;
}
#pragma mark 显示弹出框
-(void)showWithController:(UIViewController *)controller{
    if(controller){
        [controller presentViewController:_alertController animated:YES completion:nil];
    }
}
#pragma mark 静态弹出框
+(void)alertWithTitle:(NSString *)title Message:(NSString *)msg ButtonTitle:(NSString *)btnTitle Controller:(UIViewController *)controller{
    if(controller){
        ETAlert *alert = [[ETAlert alloc] initWithTitle:title Message:msg];
        if(btnTitle){
            [alert addCancelActionWithTitle:btnTitle Handler:nil];
        }
        [alert showWithController:controller];
    }
}
@end
