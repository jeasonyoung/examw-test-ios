//
//  AccountViewController+RegisterCode.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AccountViewController+RegisterCode.h"
#import "UserAccountData.h"

#define __k_account_view_register_title @"软件注册码"//
#define __k_account_view_register_msg @"请输入软件注册码："//
//注册码处理分类
@implementation AccountViewController (RegisterCode)
UIAlertController *_registerAlterController;
//注册码处理。
-(void)registerWithAccount:(UserAccountData *)account{
    if(!_registerAlterController){//惰性加载
        _registerAlterController = [UIAlertController alertControllerWithTitle:__k_account_view_register_title
                                                                       message:__k_account_view_register_msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        //
        
    }
    
    NSLog(@"registerWithAccount=>%@", account);
}
@end
