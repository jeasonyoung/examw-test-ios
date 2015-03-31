//
//  LearnTableViewCell.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//学习记录列表数据
@interface LearnTableViewCell : UITableViewCell
//试卷类型名称
@property(nonatomic,copy)NSString *paperTypeName;
//试卷标题
@property(nonatomic,copy)NSString *paperTitle;
//用时(秒)
@property(nonatomic,copy)NSNumber *useTimes;
//得分
@property(nonatomic,copy)NSNumber *score;
//最后做题时间
@property(nonatomic,copy)NSDate *lastTime;
//加载数据
-(CGFloat)loadData;
@end
