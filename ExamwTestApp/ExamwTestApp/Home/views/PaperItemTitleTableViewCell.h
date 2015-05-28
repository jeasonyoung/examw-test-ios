//
//  PaperItemTitleTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaperItemTitleModelCellFrame;
//试题标题Cell
@interface PaperItemTitleTableViewCell : UITableViewCell
//加载数据模型Cell Frame
-(void)loadModelCellFrame:(PaperItemTitleModelCellFrame *)cellFrame;
@end
