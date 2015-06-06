//
//  MoreMenuModelTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoreMenuModelCellFrame;
//更多菜单数据模型Cell
@interface MoreMenuModelTableViewCell : UITableViewCell
//加载数据模型Frame
-(void)loadModelCellFrame:(MoreMenuModelCellFrame *)cellFrame;
@end
