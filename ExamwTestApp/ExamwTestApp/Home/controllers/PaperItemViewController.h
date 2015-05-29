//
//  PaperItemViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaperItemModel;
//试卷试题视图控制器
@interface PaperItemViewController : UITableViewController

//试卷记录ID
@property(nonatomic,copy)NSString *PaperRecordId;

//初始化
-(instancetype)initWithPaperItem:(PaperItemModel *)model andOrder:(NSUInteger)order andDisplayAnswer:(BOOL)display;

@end