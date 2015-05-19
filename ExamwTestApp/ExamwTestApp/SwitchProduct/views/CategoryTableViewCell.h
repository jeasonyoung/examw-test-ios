//
//  CategoryTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryModelCellFrame.h"
//考试分类TableViewCell
@interface CategoryTableViewCell : UITableViewCell
//加载模型Frame
-(void)loadModelCellFrame:(CategoryModelCellFrame*)cellFrame;
@end
