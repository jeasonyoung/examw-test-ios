//
//  ESTimeView.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/9.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//倒计时UI代理
@class ESTimerView;
@protocol ESTimerViewDelegate <NSObject>
//计时结束事件触发
-(void)timerView:(ESTimerView *)view autoStop:(BOOL)isAuto totalUseTimes:(NSUInteger)useTimes;
@end
//倒计时UI
@interface ESTimerView : UIView
//代理属性
@property(nonatomic,assign)id<ESTimerViewDelegate> delegate;
//倒计时总时间(秒)
@property(nonatomic,assign)NSUInteger totalSec;
//初始化总时间(秒)
-(instancetype)initWithTotal:(NSUInteger)totalSec;
//开始计时
-(void)start;
//结束计时
-(void)stop;
@end
