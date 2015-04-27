//
//  SubmitBarItem.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SubmitBarItem.h"

#define __kSubmitBarItem_title @"交卷"//交卷
#define __kSubmitBarItem_cancel @"取消"
#define __kSubmitBarItem_alert @"确认"//交卷
#define __kSubmitBarItem_msg @"确认交卷？"
//交卷按钮成员变量
@interface SubmitBarItem ()<UIAlertViewDelegate>{
    UIAlertView *_alertView;
}
@end
//交卷按钮实现
@implementation SubmitBarItem
#pragma mark 初始化
-(instancetype)initWithDelegate:(id<SubmitBarItemDelegate>)delegate{
    if(self = [super initWithTitle:__kSubmitBarItem_title
                             style:UIBarButtonItemStyleBordered
                            target:self
                            action:@selector(btnSubmitClick:)]){
        _delegate = delegate;
    }
    return self;
}
//点击事件
-(void)btnSubmitClick:(UIBarButtonItem *)sender{
    _alertView = [[UIAlertView alloc]initWithTitle:__kSubmitBarItem_alert
                                           message:__kSubmitBarItem_msg
                                          delegate:self
                                 cancelButtonTitle:__kSubmitBarItem_cancel
                                 otherButtonTitles:__kSubmitBarItem_alert, nil];
    [_alertView show];
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0)return;
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickSubmitBar:)]){
        [self.delegate clickSubmitBar:self];
    }
}
@end
