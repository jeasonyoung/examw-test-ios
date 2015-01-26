//
//  BaseViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Size.h"
//视图控制器基类。
@interface BaseViewController : UIViewController
//隐藏底部TabBar
@property(nonatomic,assign)BOOL hiddenTabBar;
@end
