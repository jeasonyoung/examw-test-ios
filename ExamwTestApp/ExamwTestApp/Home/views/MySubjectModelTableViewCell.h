//
//  MySubjectModelTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MySubjectModelCellFrame;
//我的列表数据模型Cell
@interface MySubjectModelTableViewCell : UITableViewCell
//加载数据模型Cell Frame
-(void)loadModelCellFrame:(MySubjectModelCellFrame *)cellFrame;
@end
