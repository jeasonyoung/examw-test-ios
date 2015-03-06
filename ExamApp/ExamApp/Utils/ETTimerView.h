//
//  ETTimerView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//倒计时器视图
@interface ETTimerView : UIView
//初始化
-(instancetype)initWithFrame:(CGRect)frame Total:(NSInteger)total;
//停止倒计时
-(NSInteger)stop;
//用时(秒)
-(NSInteger)useTimes;
@end