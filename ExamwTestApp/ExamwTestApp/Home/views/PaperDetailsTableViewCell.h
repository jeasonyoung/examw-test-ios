//
//  PaperDetailsTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaperDetailsModelCellFrame;
//试卷明细Cell
@interface PaperDetailsTableViewCell : UITableViewCell
//加载数据模型Cell Frame
-(void)loadModelCellFrame:(PaperDetailsModelCellFrame *)cellFrame;
@end
