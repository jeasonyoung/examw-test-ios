//
//  FavoriteViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//收藏试题控制器
@interface FavoriteViewController : UIViewController
//初始化
-(instancetype)initWithSubjectCode:(NSString *)subjectCode;
//加载数据
-(void)loadDataAtOrder:(NSInteger)order;
@end
