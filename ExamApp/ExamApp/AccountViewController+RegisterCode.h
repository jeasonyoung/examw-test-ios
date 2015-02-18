//
//  AccountViewController+RegisterCode.h
//  ExamApp
//
//  Created by jeasonyoung on 15/2/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AccountViewController.h"
@class UserAccountData;
//注册码
@interface AccountViewController (RegisterCode)<UITextFieldDelegate>
//注册码处理。
-(void)registerWithAccount:(UserAccountData *)account;
@end