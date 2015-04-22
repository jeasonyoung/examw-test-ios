//
//  LearnTableViewCell.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LearnRecordCellData;
//学习记录列表数据
@interface LearnTableViewCell : UITableViewCell
//加载数据
-(void)loadData:(LearnRecordCellData *)data;
@end
