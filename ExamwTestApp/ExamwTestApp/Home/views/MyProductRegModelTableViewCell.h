//
//  MyProductRegModelTableViewCell.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//产品注册数据模型Cell代理
@class MyProductRegModelTableViewCell;
@protocol MyProductRegModelTableViewCellDelegate <NSObject>
//注册按钮点击
-(void)productRegCell:(MyProductRegModelTableViewCell *)cell btnClick:(UIButton *)sender regCode:(NSString *)regCode;
@end

@class MyProductRegModelCellFrame;
//产品注册数据模型Cell
@interface MyProductRegModelTableViewCell : UITableViewCell
//代理
@property(nonatomic,assign)id<MyProductRegModelTableViewCellDelegate> delegate;
//加载数据模型Frame
-(void)loadModelCellFrame:(MyProductRegModelCellFrame *)cellFrame;
@end
