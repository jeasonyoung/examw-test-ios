//
//  PaperResultTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//试卷结果Cell
@class PaperResultModelCellFrame;
@interface PaperResultTableViewCell : UITableViewCell
//加载数据模型Frame
-(void)loadModelCellFrame:(PaperResultModelCellFrame *)cellFrame;
@end
