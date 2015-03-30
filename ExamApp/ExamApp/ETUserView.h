//
//  ETUserView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/24.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//用户信息面板
@protocol ETUserViewDelegate <NSObject>
//考试日期
-(NSDate *)userViewForExamDate;
//当前用户
-(NSString *)userViewForCurrentUser;
@end

//用户信息面板
@interface ETUserView : UIView
//用户信息面板代理
@property(nonatomic,assign)id<ETUserViewDelegate> delegate;
//创建面板
-(void)createPanel;
//更新倒计时
-(void)updateDownTime;
@end
