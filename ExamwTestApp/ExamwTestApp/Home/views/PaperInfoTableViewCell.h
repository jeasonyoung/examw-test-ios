//
//  PaperInfoTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaperInfoModelCellFrame;
//试卷信息Cell
@interface PaperInfoTableViewCell : UITableViewCell

//加载数据模型Frame
-(void)loadModelCellFrame:(PaperInfoModelCellFrame *)cellFrame;
@end
