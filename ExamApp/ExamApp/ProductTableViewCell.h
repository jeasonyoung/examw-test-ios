//
//  ProductTableViewCell.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductDataCellFrame;
//产品列表数据
@interface ProductTableViewCell : UITableViewCell
//加载数据
-(void)loadDataWithProduct:(ProductDataCellFrame *)cellData;
@end
