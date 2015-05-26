//
//  PaperButtonTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaperButtonModelCellFrame;
//试卷按钮Cell
@interface PaperButtonTableViewCell : UITableViewCell
//加载数据模型Frame
-(void)loadModelCellFrame:(PaperButtonModelCellFrame *)cellFrame;
@end
