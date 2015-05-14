//
//  AppDelegate.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppSettings.h"
//应用入口
@interface AppDelegate : UIResponder <UIApplicationDelegate>
//主窗体
@property(nonatomic, strong) UIWindow *window;
//应用程序配置
@property(nonatomic,strong,readonly)AppSettings *appSettings;
@end
