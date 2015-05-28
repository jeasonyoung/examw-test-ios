//
//  PaperItemAnalysisTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaperItemAnalysisModelCellFrame;
//题目答案解析Cell
@interface PaperItemAnalysisTableViewCell : UITableViewCell
//加载数据模型Cell Frame
-(void)loadModelCellFrame:(PaperItemAnalysisModelCellFrame *)cellFrame;
@end
