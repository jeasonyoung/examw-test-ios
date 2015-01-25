//
//  ETUserViewDataSource.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/24.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ETUserView;
//用户信息面板数据源
@protocol ETUserViewDelegate<NSObject>
//必须项
@required
//倒计时目标日期时间
-(NSDate *)countDownTargetDateInUserView:(ETUserView *)userView;
//可选项
@optional
//日期时间
-(NSDate *)dateInUserView:(ETUserView *)userView;
//日期时间的字体
-(UIFont *)dateFontInUserView:(ETUserView *)userView;
//用户名称
-(NSString *)userNameInUserView:(ETUserView *)userView;
//用户名称的字体
-(UIFont *)userNameFontInUserView:(ETUserView *)userView;
//倒计时标签
-(NSString *)countDownTitleInUserView:(ETUserView *)userView;
//倒计时标签的字体
-(UIFont *)countDownTitleFontInUserView:(ETUserView *)userView;
//倒计时显示内容
-(NSString *)countDownContentInUserView:(ETUserView *)userView withInterval:(int)interval;
//倒计时显示内容字体
-(UIFont *)countDownContentFontInUserView:(ETUserView *)userView;
@end
