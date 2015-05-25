//
//  PaperRealViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//真题视图控制器
@interface PaperInfoViewController : UITableViewController
//初始化
-(instancetype)initWithType:(NSUInteger)type parentViewController:(UIViewController *)parent;
//静态初始化
+(instancetype)infoControllerWithType:(NSUInteger)type parentViewController:(UIViewController *)parent;
@end
