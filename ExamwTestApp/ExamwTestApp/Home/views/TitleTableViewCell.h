//
//  TitleTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TitleModelCellFrame;
//标题内容Cell
@interface TitleTableViewCell : UITableViewCell
//加载数据模型Frame.
-(void)loadModelCellFrame:(TitleModelCellFrame *)cellFrame;
@end