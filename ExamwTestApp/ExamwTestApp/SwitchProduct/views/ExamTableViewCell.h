//
//  ExamTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ExamModelCellFrame;
//考试TableViewCell
@interface ExamTableViewCell : UITableViewCell
//加载考试数据Frame
-(void)loadModelCellFrame:(ExamModelCellFrame *)cellFrame;
@end
