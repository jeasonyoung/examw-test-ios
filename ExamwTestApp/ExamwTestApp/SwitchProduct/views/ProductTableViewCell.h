//
//  ProductTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProductModelCellFrame.h"
//产品TableViewCell
@interface ProductTableViewCell : UITableViewCell
//加载数据模型Cell Frame。
-(void)loadModelCellFrame:(ProductModelCellFrame *)cellFrame;
@end
