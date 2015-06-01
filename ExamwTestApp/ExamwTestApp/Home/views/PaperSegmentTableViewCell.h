//
//  PaperSegmentTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//试卷分段Cell
@class PaperSegmentModelCellFrame;
@interface PaperSegmentTableViewCell : UITableViewCell
//加载数据模型Frame
-(void)loadModelCellFrame:(PaperSegmentModelCellFrame *)cellFrame;
@end
