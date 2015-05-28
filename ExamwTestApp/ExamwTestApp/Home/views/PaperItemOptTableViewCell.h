//
//  PaperItemOptTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaperItemOptModelCellFrame;
//试题选项Cell
@interface PaperItemOptTableViewCell : UITableViewCell
//加载数据模型Cell Frame
-(void)loadModelCellFrame:(PaperItemOptModelCellFrame *)cellFrame;
@end
