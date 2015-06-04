//
//  PaperRecordModelTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaperRecordModelCellFrame;
//试卷做题记录数据模型Cell
@interface PaperRecordModelTableViewCell : UITableViewCell
//加载试卷数据模型Cell Frame
-(void)loadModelCellFrame:(PaperRecordModelCellFrame *)cellFrame;
@end
