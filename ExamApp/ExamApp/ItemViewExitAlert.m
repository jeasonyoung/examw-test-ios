//
//  ItemViewExitAlert.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemViewExitAlert.h"

#define __kItemViewExitAlert_title @"退出"//
#define __kItemViewExitAlert_msg @"是否退出考试?"
#define __kItemViewExitAlert_btnCancel @"取消"
#define __kItemViewExitAlert_btnSubmit @"交卷"
#define __kItemViewExitAlert_btnConfirm @"下次再做"
//试题视图退出对话框成员变量
@interface ItemViewExitAlert ()<UIAlertViewDelegate>{
    UIAlertView *_alertView;
}
@end
//试题视图退出对话框实现
@implementation ItemViewExitAlert
#pragma mark 初始化
-(instancetype)init{
    if(self = [super init]){
        _alertView = [[UIAlertView alloc]initWithTitle:__kItemViewExitAlert_title
                                               message:__kItemViewExitAlert_msg
                                              delegate:self
                                     cancelButtonTitle:__kItemViewExitAlert_btnCancel
                                     otherButtonTitles:__kItemViewExitAlert_btnSubmit,
                                        __kItemViewExitAlert_btnConfirm, nil];
    }
    return self;
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(self.delegate && [self.delegate respondsToSelector:@selector(alertExitWithTag:)]){
        [self.delegate alertExitWithTag:buttonIndex];
    }
}
#pragma mark 显示对话框
-(void)showAlert{
    [_alertView show];
}
@end
