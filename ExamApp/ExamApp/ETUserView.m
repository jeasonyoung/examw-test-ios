//
//  ETUserView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/24.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ETUserView.h"
#import "NSString+Size.h"
#import "NSString+Date.h"
#import "UIColor+Hex.h"
#import "NSDate+TimeZone.h"

#import "ETUserViewDelegate.h"

#define __k_banner_top 4//顶部间距
#define __k_banner_left 4//左边间距
#define __k_banner_right 4//右边间距
#define __k_banner_view_margin 5//banner内View与边框的间距
#define __k_banner_inner_margin 2 //内部间距
#define __k_banner_icon_cal_with 29 //日历图标宽度
#define __k_banner_icon_cal_height 28 //日历图标的高度
#define __k_banner_icon_user_width 25//用户图标宽度
#define __k_banner_icon_user_height 25//用户图标高度


//用户信息面板成员变量
@interface ETUserView(){
    UIFont *_defont;
}
@end
//用户信息面板实现类
@implementation ETUserView
#pragma mark 创建面板
-(void)createPanel{
    [self createPanelWithFrame:self.frame];
}
-(void)createPanelWithFrame:(CGRect)frame{
    _defont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    CGFloat x = __k_banner_left, y = __k_banner_top, w = frame.size.width - __k_banner_left - __k_banner_right;
    NSDate *current = [[NSDate date] localTime];
    if(_delegate && [_delegate respondsToSelector:@selector(dateInUserView:)]){
        current = [_delegate dateInUserView:self];
    }
    //添加日历面板
    UIView *calView = [self createCalcuateWithCalDate:current];
    CGRect calViewFrame = calView.frame;
    calViewFrame.origin.x = x;
    calViewFrame.origin.y = y;
    calView.frame = calViewFrame;
    //添加到面板
    [self addSubview:calView];
    NSLog(@"calView => %@", calView);
    
    //添加用户面板
    CGFloat userViewWidth = w - calViewFrame.size.width -__k_banner_view_margin;
    UIView *userView = [self createUserViewWithWidth:userViewWidth];
    CGRect userViewFrame = userView.frame;
    userViewFrame.origin.x = w - userViewFrame.size.width;
    userViewFrame.origin.y = y;
    userView.frame = userViewFrame;
    y += userViewFrame.size.height;
    //添加到面板
    [self addSubview:userView];
    NSLog(@"userView = %@", userView);
    
    //添加倒计时面板
    UIView *cdView = [self createCountdownWithWidth:w andCurrentDate:current];
    CGRect cdViewFrame = cdView.frame;
    cdViewFrame.origin.x = x;
    cdViewFrame.origin.y = y + __k_banner_top;
    cdView.frame = cdViewFrame;
    //添加到面板
    [self addSubview:cdView];
    NSLog(@"cdView = %@", cdView);
    
    //面板设置
    CGFloat minHeight = cdViewFrame.origin.y + cdViewFrame.size.height + __k_banner_top;
    frame.size.height = frame.size.height > minHeight ? minHeight : frame.size.height;//重置高度
    self.frame = frame;
    self.backgroundColor = [UIColor colorWithHex:0xF8F8F8];//设置背景色
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8.5;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [[UIColor colorWithHex:0xDEDEDE] CGColor];
    
    NSLog(@"ETUserView => %@",self);
}
#pragma mark 创建日历面板
-(UIView *)createCalcuateWithCalDate:(NSDate *)cal{
    //获取字体
    UIFont *font = _defont;
    if(_delegate && [_delegate respondsToSelector:@selector(dateFontInUserView:)]){
        font = [_delegate dateFontInUserView:self];
    }
    //初始化日历版面
    UIView *calView = [[UIView alloc] init];
    //日历图标
    UIImageView *iconCal = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_calculate.png"]];
    iconCal.contentMode = UIViewContentModeScaleAspectFit;
    iconCal.frame = CGRectMake(0, 0, __k_banner_icon_cal_with, __k_banner_icon_cal_height);
    [calView addSubview:iconCal];
    //日期
    NSString *calText = [NSString stringFromDate:cal];//日期字符串
    CGSize calSize = [calText sizeWithFont:font];//日期字符串尺寸
    CGRect tempFrame = iconCal.frame;
    tempFrame.origin.x += tempFrame.size.width + __k_banner_inner_margin;
    tempFrame.origin.y  = (__k_banner_icon_cal_height - calSize.height)/2;
    tempFrame.size = calSize;
    UILabel *lbCal = [[UILabel alloc] initWithFrame:tempFrame];
    lbCal.text = calText;
    lbCal.font = font;
    [calView addSubview:lbCal];
    //设置面板尺寸
    CGRect calViewFrame = lbCal.frame;
    calViewFrame.size.width += calViewFrame.origin.x + __k_banner_inner_margin;
    calViewFrame.size.height = __k_banner_icon_cal_height;
    calViewFrame.origin = CGPointMake(0, 0);
    calView.frame = calViewFrame;
    return calView;
}
#pragma mark 创建用户信息面板
-(UIView *)createUserViewWithWidth:(CGFloat)width {
    UIView *userView = [[UIView alloc] init];
    //用户图标
    UIImageView *iconUser = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_username.png"]];
    iconUser.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat iconHeight = (__k_banner_icon_user_height > __k_banner_icon_cal_height) ? __k_banner_icon_user_height : __k_banner_icon_cal_height;
    iconUser.frame = CGRectMake(0, (iconHeight - __k_banner_icon_user_height)/2, __k_banner_icon_user_width, __k_banner_icon_user_height);
    [userView addSubview:iconUser];
    NSString *name = @"jeasonyoung";
    if(_delegate && [_delegate respondsToSelector:@selector(userNameInUserView:)]){
        name = [_delegate userNameInUserView:self];
    }
    UIFont *font = _defont;
    if(_delegate && [_delegate respondsToSelector:@selector(userNameFontInUserView:)]){
        font = [_delegate userNameFontInUserView:self];
    }
    //用户名称
    CGSize nameSize = [name sizeWithFont:font];
    CGRect tempFrame = iconUser.frame;
    tempFrame.origin.x += tempFrame.size.width + __k_banner_inner_margin;
    tempFrame.origin.y = (tempFrame.size.height - nameSize.height)/2;
    CGFloat tempWidth = tempFrame.origin.x + nameSize.width + __k_banner_inner_margin;//实现宽度
    tempFrame.size.width = width > tempWidth ? nameSize.width : width - tempFrame.origin.x;
    UILabel *lbName = [[UILabel alloc] initWithFrame:tempFrame];
    lbName.text = name;
    lbName.font = font;
    [userView addSubview:lbName];
    //用户信息面板
    CGRect userViewFrame = lbName.frame;
    userViewFrame.size.width += userViewFrame.origin.x + __k_banner_inner_margin;
    userViewFrame.origin = CGPointMake(0, 0);
    userView.frame = userViewFrame;
    return userView;
}
#pragma mark 创建倒计时面板
-(UIView *)createCountdownWithWidth:(CGFloat)width andCurrentDate:(NSDate *)current{
    UIView *cdView = [[UIView alloc] init];
    //标题
    NSString *title = @"距离考试仅剩：";
    if(_delegate && [_delegate respondsToSelector:@selector(countDownTitleInUserView:)]){
        title = [_delegate countDownTitleInUserView:self];
    }
    //标题字体
    UIFont *titleFont = _defont;
    if(_delegate && [_delegate respondsToSelector:@selector(countDownTitleFontInUserView:)]){
        titleFont = [_delegate countDownTitleFontInUserView:self];
    }
    //标题
    CGSize titleSize = [title sizeWithFont:titleFont];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleSize.width + __k_banner_inner_margin, titleSize.height)];
    lbTitle.text = title;
    lbTitle.font = titleFont;
    [cdView addSubview:lbTitle];
    //倒计时开始时间
    NSDate *dtStart = [NSDate currentLocalTime];
    if(_delegate && [_delegate respondsToSelector:@selector(countDownTargetDateInUserView:)]){
        dtStart = [_delegate countDownTargetDateInUserView:self];
    }
    //倒计时值
    int interval = [dtStart dayIntervalSinceDate:current];
    NSString *text = interval >= 0 ? [NSString stringWithFormat:@"%d 天", (int)interval] : @"本次考试已结束";
    if(interval == 0){
        text = @"今日考试";
    }
    if(_delegate && [_delegate respondsToSelector:@selector(countDownContentInUserView:withInterval:)]){
        text = [_delegate countDownContentInUserView:self withInterval:interval];
    }
    //倒计时字体
    UIFont *textFont = _defont;
    if(_delegate && [_delegate respondsToSelector:@selector(countDownContentFontInUserView:)]){
        textFont = [_delegate countDownContentFontInUserView:self];
    }
    CGSize textSize = [text sizeWithFont:textFont];
    CGRect tempFrame = lbTitle.frame;
    tempFrame.origin.x += tempFrame.size.width;
    CGFloat tempWidth = tempFrame.origin.x + textSize.width + __k_banner_inner_margin;//实际宽度
    tempFrame.size.width = width > tempWidth ? textSize.width : width - tempFrame.origin.x;
    UILabel *lbText = [[UILabel alloc] initWithFrame:tempFrame];
    lbText.text = text;
    lbText.font = textFont;
    [cdView addSubview:lbText];
    //倒计时面板
    CGRect cdViewFrame = lbText.frame;
    cdViewFrame.size.width += cdViewFrame.origin.x + __k_banner_inner_margin;
    cdViewFrame.origin = CGPointMake(0, 0);
    cdView.frame = cdViewFrame;
    return cdView;
}
@end