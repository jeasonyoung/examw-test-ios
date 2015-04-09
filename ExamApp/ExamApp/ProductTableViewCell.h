//
//  ProductTableViewCell.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/8.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductData.h"
//产品列表数据
@interface ProductTableViewCell : UITableViewCell
//加载数据
-(CGFloat)loadDataWithProduct:(ProductData *)data;
@end
