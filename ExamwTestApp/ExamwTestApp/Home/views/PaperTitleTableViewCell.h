//
//  PaperTitleTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaperTitleModelCellFrame;
//试卷标题Cell
@interface PaperTitleTableViewCell : UITableViewCell

//加载数据模型Frame
-(void)loadModelCellFrame:(PaperTitleModelCellFrame *)cellFrame;
@end
