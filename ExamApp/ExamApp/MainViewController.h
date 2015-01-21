//
//  MainViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//主菜单视图控制器
@interface MainViewController : UIViewController


//切换视图控制器
-(void)gotoControllerWithParent:(UIViewController *)parent animated:(BOOL)isAnimate;
@end