//
//  ProductViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//产品列表控制器
@interface ProductViewController : UITableViewController
//初始化
-(instancetype)initWithExamId:(NSString *)examId;
@end
