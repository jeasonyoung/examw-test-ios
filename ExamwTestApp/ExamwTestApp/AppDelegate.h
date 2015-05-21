//
//  AppDelegate.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppSettings;
@class UserAccount;

//应用入口
@interface AppDelegate : UIResponder <UIApplicationDelegate>
//主窗体
@property(nonatomic,strong) UIWindow *window;

//应用程序配置
@property(nonatomic,strong,readonly)AppSettings *appSettings;

//获取当前用户
@property(nonatomic,strong,readonly)UserAccount *currentUser;

//切换用户
-(void)changedCurrentUser:(UserAccount *)userAccount;
@end
