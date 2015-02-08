//
//  AccountViewController+Logout.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AccountViewController.h"
@class UserAccountData;
//用户注销处理
@interface AccountViewController (Logout)
//注销账号
-(void)logoutWithAccount:(UserAccountData *)account;
@end