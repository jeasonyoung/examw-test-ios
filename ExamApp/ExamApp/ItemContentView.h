//
//  ItemTestView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/7.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperReview.h"
//考试试题视图
@interface ItemContentView : UIScrollView
//初始化
-(instancetype)initWithFrame:(CGRect)frame;
//加载数据
-(void)loadDataWithItem:(PaperItem *)item Order:(NSInteger)order;
//加载数据
-(void)loadDataWithItem:(PaperItem *)item Order:(NSInteger)order Index:(NSInteger)index;
@end

