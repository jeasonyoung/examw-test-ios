//
//  UserBannerView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserBannerView : UIView
//当前日期
@property(nonatomic,weak) IBOutlet UILabel *calculateLabel;
//当前用户
@property(nonatomic,weak) IBOutlet UILabel *userNameLabel;
//考试倒计时
@property(nonatomic,weak) IBOutlet UILabel *timeLabel;
//静态函数
+(id) userBanner;
//
-(void)setUserDataWithUser:(NSString *)name andTime:(int)time;
@end
