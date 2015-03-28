//
//  WrongViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//错题重做视图控制器
@interface WrongViewController : UIViewController
//初始化
-(instancetype)initWithSubjectCode:(NSString *)subjectCode;
//加载数据
-(void)loadDataAtOrder:(NSInteger)order;
@end
