//
//  SubjectTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/16.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//科目Cell
@class SubjectModelCellFrame;
@interface SubjectTableViewCell : UITableViewCell
//加载数据模型Frame
-(void)loadModelCellFrame:(SubjectModelCellFrame *)cellFrame;
@end
