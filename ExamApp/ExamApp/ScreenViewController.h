//
//  ScreenViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "BaseViewController.h"
#import "SettingData.h"
//屏幕亮度控制器
@interface ScreenViewController : BaseViewController
//初始化
-(instancetype)initWithSetting:(SettingData *)data;
@end
