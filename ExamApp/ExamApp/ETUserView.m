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

#import "UIViewUtils.h"

#define __kETUserView_top 5//顶部间距
#define __kETUserView_left 5//左边间距
#define __kETUserView_right 5//右边间距
#define __kETUserView_bottom 5//底部间距

#define __kETUserView_view_margin 5//banner内View与边框的间距
#define __kETUserView_inner_margin 2 //内部间距
#define __kETUserView_icon_cal_with 25 //日历图标宽度
#define __kETUserView_icon_cal_height 25 //日历图标的高度
#define __kETUserView_icon_user_width 25//用户图标宽度
#define __kETUserView_icon_user_height 25//用户图标高度

#define __kETUserView_bgColor 0xF8F8F8//背景色
#define __kETUserView_borderColor 0xDEDEDE//边框色

#define __kETUserView_icon_cal @"user_calculate.png"//日历图标
#define __kETUserView_icon_user @"user_username.png"//用户图标
#define __kETUserView_dateFormate @"yyyy-MM-dd"//日期格式

#define __kETUserView_countdownTitle @"距离考试仅剩："//
#define __kETUserView_conntdownContent_fontColor 0xFE3200//倒计时字体颜色
#define __kETUserView_countdown_nosettings @"未设置考试日期"
#define __kETUserView_countdown_text @"%d 天"//倒计时
#define __kETUserView_countdown_end @"本次考试已结束"//
#define __kETUserView_countdown_date @"今日考试"//
//用户信息面板成员变量
@interface ETUserView(){
    UIFont *_font;
    UILabel *_lbCountdownContent;
}
@end
//用户信息面板实现类
@implementation ETUserView
#pragma mark 创建面板
-(void)createPanel{
    //初始化字体
    _font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    //
    NSNumber *outY = [NSNumber numberWithFloat:0];
    //日历
    [self setupCalcuateWithFrame:self.frame OutY:&outY];
    //用户
    [self setupUserWithFrame:self.frame OutY:&outY];
    //倒计时
    [self setupCountdownWithFrame:self.frame OutY:&outY];
    //重置高度
    CGRect tempFrame = self.frame;
    tempFrame.size.height = outY.floatValue + __kETUserView_bottom;
    self.frame = tempFrame;
    //
    [UIViewUtils addBoundsRadiusWithView:self
                             BorderColor:[UIColor colorWithHex:__kETUserView_borderColor]
                         BackgroundColor:[UIColor colorWithHex:__kETUserView_bgColor]];

}
//日历
-(void)setupCalcuateWithFrame:(CGRect)frame OutY:(NSNumber **)outY{
    //初始化面板
    UIView *panel = [[UIView alloc]initWithFrame:CGRectMake(0, __kETUserView_top, CGRectGetWidth(frame)/2, 0)];
    //
    CGFloat maxHeight = __kETUserView_icon_cal_height;
    //icon
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:__kETUserView_icon_cal]];
    imgView.frame = CGRectMake(__kETUserView_left, 0, __kETUserView_icon_cal_with, __kETUserView_icon_cal_height);
    [panel addSubview:imgView];
    //text
    NSDate *current = [NSDate currentLocalTime];
    NSString *calText = [NSString stringFromDate:current withDateFormat:__kETUserView_dateFormate];
    if(calText && calText.length > 0){
        CGFloat width = CGRectGetWidth(panel.frame) - CGRectGetMaxX(imgView.frame) - __kETUserView_inner_margin;
        CGSize calTextSize = [calText sizeWithFont:_font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        if(maxHeight < calTextSize.height){
            maxHeight = calTextSize.height;
        }
        UILabel *lbCalText = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgView.frame)+ __kETUserView_inner_margin,
                                                                      (maxHeight - calTextSize.height)/2, width, calTextSize.height)];
        lbCalText.font = _font;
        lbCalText.textAlignment = NSTextAlignmentLeft;
        lbCalText.text = calText;
        [panel addSubview:lbCalText];
    }
    //重置尺寸
    CGRect tempFrame = panel.frame;
    tempFrame.size.height = maxHeight;
    panel.frame = tempFrame;
    [self addSubview:panel];
    //输出y坐标
    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(panel.frame)];
}
//用户
-(void)setupUserWithFrame:(CGRect)frame OutY:(NSNumber **)outY{
    //初始化面板
    UIView *panel = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(frame)/2, __kETUserView_top, CGRectGetWidth(frame)/2, 0)];
    //
    CGFloat maxHeight = __kETUserView_icon_user_height;
    //icon
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:__kETUserView_icon_user]];
    imgView.frame = CGRectMake(__kETUserView_left, 0, __kETUserView_icon_user_width, __kETUserView_icon_user_height);
    [panel addSubview:imgView];
    //text
    NSString *userText = nil;
    if(_delegate && [_delegate respondsToSelector:@selector(userViewForCurrentUser)]){
        userText = [_delegate userViewForCurrentUser];
    }
    if(userText && userText.length > 0){
        CGFloat width = CGRectGetWidth(panel.frame) - CGRectGetMaxX(imgView.frame) - __kETUserView_inner_margin;
        CGSize userTextSize = [userText sizeWithFont:_font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        if(maxHeight < userTextSize.height){
            maxHeight = userTextSize.height;
        }
        UILabel *lbUserText = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgView.frame)+ __kETUserView_inner_margin,
                                                                      (maxHeight - userTextSize.height)/2, width, userTextSize.height)];
        lbUserText.font = _font;
        lbUserText.textAlignment = NSTextAlignmentLeft;
        lbUserText.text = userText;
        [panel addSubview:lbUserText];
    }
    //重置尺寸
    CGRect tempFrame = panel.frame;
    tempFrame.size.height = maxHeight;
    panel.frame = tempFrame;
    [self addSubview:panel];
    //输出y坐标
    if(CGRectGetMaxY(panel.frame) > (*outY).floatValue){
        *outY = [NSNumber numberWithFloat:CGRectGetMaxY(panel.frame)];
    }
}
//倒计时
-(void)setupCountdownWithFrame:(CGRect)frame OutY:(NSNumber **)outY{
    //初始化容器面板
    UIView *panel = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                            (*outY).floatValue + __kETUserView_view_margin + __kETUserView_top,
                                                            CGRectGetWidth(frame), 0)];
    //倒计时标题
    CGSize titleSize = [__kETUserView_countdownTitle sizeWithFont:_font
                                                constrainedToSize:CGSizeMake(CGRectGetWidth(panel.frame), CGFLOAT_MAX)
                                                    lineBreakMode:NSLineBreakByWordWrapping];
    UILabel *lbTitle = [[UILabel alloc]initWithFrame:CGRectMake(__kETUserView_left, 0, titleSize.width, titleSize.height)];
    lbTitle.font = _font;
    lbTitle.textAlignment = NSTextAlignmentLeft;
    lbTitle.text = __kETUserView_countdownTitle;
    [panel addSubview:lbTitle];
    //倒计时内容
    _lbCountdownContent = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lbTitle.frame) + __kETUserView_inner_margin, 0,
                                        CGRectGetWidth(panel.frame) - CGRectGetMaxX(lbTitle.frame) - __kETUserView_inner_margin,
                                                                   titleSize.height)];
    _lbCountdownContent.font = _font;
    _lbCountdownContent.textColor = [UIColor colorWithHex:__kETUserView_conntdownContent_fontColor];
    //
    [self updateDownTime];
    [panel addSubview:_lbCountdownContent];
    //重置尺寸
    CGRect tempFrame = panel.frame;
    tempFrame.size.height = titleSize.height;
    panel.frame = tempFrame;
    [self addSubview:panel];
    //
    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(panel.frame)];
}
//更新倒计时
-(void)updateDownTime{
    if(!_lbCountdownContent)return;
    //考试日期
    NSDate *endDate;
    //获取考试日期
    if(self.delegate && [self.delegate respondsToSelector:@selector(userViewForExamDate)]){
        endDate = [self.delegate userViewForExamDate];
    }
    //
    if(!endDate){
        _lbCountdownContent.text = __kETUserView_countdown_nosettings;
        return;
    }
    //当前日期
    NSDate *current = [NSDate currentLocalTime];
    //倒计时值
    int interval = [endDate dayIntervalSinceDate:current];
    //
    NSString *text = interval >= 0 ? [NSString stringWithFormat:__kETUserView_countdown_text, interval] : __kETUserView_countdown_end;
    if(interval == 0){
        text = __kETUserView_countdown_date;
    }
    _lbCountdownContent.text = text;
}
//-(void)createPanelWithFrame:(CGRect)frame{
//    _defont = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];//UIFontTextStyleHeadline
//    CGFloat x = __kETUserView_left, y = __kETUserView_top,
//    w = CGRectGetWidth(frame) - __kETUserView_left - __kETUserView_right;
//    NSDate *current = [NSDate currentLocalTime];
//    if(_delegate && [_delegate respondsToSelector:@selector(dateInUserView:)]){
//        current = [_delegate dateInUserView:self];
//    }
//    //添加日历面板
//    UIView *calView = [self createCalcuateWithCalDate:current];
//    CGRect calViewFrame = calView.frame;
//    calViewFrame.origin.x = x;
//    calViewFrame.origin.y = y;
//    calView.frame = calViewFrame;
//    //添加到面板
//    [self addSubview:calView];
//    //NSLog(@"calView => %@", calView);
//    
//    //添加用户面板
//    CGFloat userViewWidth = w - CGRectGetWidth(calViewFrame) -__kETUserView_view_margin;
//    UIView *userView = [self createUserViewWithWidth:userViewWidth];
//    CGRect userViewFrame = userView.frame;
//    userViewFrame.origin.x = w - userViewFrame.size.width;
//    userViewFrame.origin.y = y;
//    userView.frame = userViewFrame;
//    y += userViewFrame.size.height;
//    //添加到面板
//    [self addSubview:userView];
//    //NSLog(@"userView = %@", userView);
//    
//    //添加倒计时面板
//    UIView *cdView = [self createCountdownWithWidth:w andCurrentDate:current];
//    CGRect cdViewFrame = cdView.frame;
//    cdViewFrame.origin.x = x;
//    cdViewFrame.origin.y = y + __kETUserView_top;
//    cdView.frame = cdViewFrame;
//    //添加到面板
//    [self addSubview:cdView];
//    //NSLog(@"cdView = %@", cdView);
//    
//    //面板设置
//    CGFloat minHeight = CGRectGetMaxY(cdViewFrame) + __kETUserView_top;
//    frame.size.height = frame.size.height > minHeight ? minHeight : frame.size.height;//重置高度
//    self.frame = frame;
//    
//    [UIViewUtils addBoundsRadiusWithView:self
//                             BorderColor:[UIColor colorWithHex:__kETUserView_borderColor]
//                         BackgroundColor:[UIColor colorWithHex:__kETUserView_bgColor]];
//    
////    self.backgroundColor = [UIColor colorWithHex:0xF8F8F8];//设置背景色
////    self.layer.masksToBounds = YES;
////    self.layer.cornerRadius = 8.5;
////    self.layer.borderWidth = 1.0;
////    self.layer.borderColor = [[UIColor colorWithHex:0xDEDEDE] CGColor];
//    //NSLog(@"ETUserView => %@",self);
//}
//#pragma mark 创建日历面板
//-(UIView *)createCalcuateWithCalDate:(NSDate *)cal{
//    //获取字体
//    UIFont *font = _defont;
//    if(_delegate && [_delegate respondsToSelector:@selector(dateFontInUserView:)]){
//        font = [_delegate dateFontInUserView:self];
//    }
//    //初始化日历版面
//    UIView *calView = [[UIView alloc] init];
//    //日历图标
//    UIImageView *iconCal = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_calculate.png"]];
//    iconCal.contentMode = UIViewContentModeScaleAspectFit;
//    iconCal.frame = CGRectMake(0, 0, __k_banner_icon_cal_with, __k_banner_icon_cal_height);
//    [calView addSubview:iconCal];
//    //日期
//    NSString *calText = [NSString stringFromDate:cal withDateFormat:@"yyyy-MM-dd"];//日期字符串
//    CGSize calSize = [calText sizeWithFont:font];//日期字符串尺寸
//    CGRect tempFrame = iconCal.frame;
//    tempFrame.origin.x += tempFrame.size.width + __k_banner_inner_margin;
//    tempFrame.origin.y  = (__k_banner_icon_cal_height - calSize.height)/2;
//    tempFrame.size = calSize;
//    UILabel *lbCal = [[UILabel alloc] initWithFrame:tempFrame];
//    lbCal.text = calText;
//    lbCal.font = font;
//    [calView addSubview:lbCal];
//    //设置面板尺寸
//    CGRect calViewFrame = lbCal.frame;
//    calViewFrame.size.width += calViewFrame.origin.x + __k_banner_inner_margin;
//    calViewFrame.size.height = __k_banner_icon_cal_height;
//    calViewFrame.origin = CGPointMake(0, 0);
//    calView.frame = calViewFrame;
//    return calView;
//}
//#pragma mark 创建用户信息面板
//-(UIView *)createUserViewWithWidth:(CGFloat)width {
//    UIView *userView = [[UIView alloc] init];
//    //用户图标
//    UIImageView *iconUser = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_username.png"]];
//    iconUser.contentMode = UIViewContentModeScaleAspectFit;
//    CGFloat iconHeight = (__k_banner_icon_user_height > __k_banner_icon_cal_height) ? __k_banner_icon_user_height : __k_banner_icon_cal_height;
//    iconUser.frame = CGRectMake(0, (iconHeight - __k_banner_icon_user_height)/2, __k_banner_icon_user_width, __k_banner_icon_user_height);
//    [userView addSubview:iconUser];
//    NSString *name = @"jeasonyoung";
//    if(_delegate && [_delegate respondsToSelector:@selector(userNameInUserView:)]){
//        name = [_delegate userNameInUserView:self];
//    }
//    UIFont *font = _defont;
//    if(_delegate && [_delegate respondsToSelector:@selector(userNameFontInUserView:)]){
//        font = [_delegate userNameFontInUserView:self];
//    }
//    //用户名称
//    CGSize nameSize = [name sizeWithFont:font];
//    CGRect tempFrame = iconUser.frame;
//    tempFrame.origin.x += tempFrame.size.width + __k_banner_inner_margin;
//    tempFrame.origin.y = (tempFrame.size.height - nameSize.height)/2;
//    CGFloat tempWidth = tempFrame.origin.x + nameSize.width + __k_banner_inner_margin;//实现宽度
//    tempFrame.size.width = width > tempWidth ? nameSize.width : width - tempFrame.origin.x;
//    UILabel *lbName = [[UILabel alloc] initWithFrame:tempFrame];
//    lbName.text = name;
//    lbName.font = font;
//    [userView addSubview:lbName];
//    //用户信息面板
//    CGRect userViewFrame = lbName.frame;
//    userViewFrame.size.width += userViewFrame.origin.x + __k_banner_inner_margin;
//    userViewFrame.origin = CGPointMake(0, 0);
//    userView.frame = userViewFrame;
//    return userView;
//}
//#pragma mark 创建倒计时面板
//-(UIView *)createCountdownWithWidth:(CGFloat)width andCurrentDate:(NSDate *)current{
//    UIView *cdView = [[UIView alloc] init];
//    //标题
//    NSString *title = @"距离考试仅剩：";
//    if(_delegate && [_delegate respondsToSelector:@selector(countDownTitleInUserView:)]){
//        title = [_delegate countDownTitleInUserView:self];
//    }
//    //标题字体
//    UIFont *titleFont = _defont;
//    if(_delegate && [_delegate respondsToSelector:@selector(countDownTitleFontInUserView:)]){
//        titleFont = [_delegate countDownTitleFontInUserView:self];
//    }
//    //标题
//    CGSize titleSize = [title sizeWithFont:titleFont];
//    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleSize.width + __k_banner_inner_margin, titleSize.height)];
//    lbTitle.text = title;
//    lbTitle.font = titleFont;
//    [cdView addSubview:lbTitle];
//    
////    //倒计时开始时间
////    NSDate *dtStart = [NSDate currentLocalTime];
////    if(_delegate && [_delegate respondsToSelector:@selector(countDownTargetDateInUserView:)]){
////        dtStart = [_delegate countDownTargetDateInUserView:self];
////    }
////    //倒计时值
////
////
////    if(interval == 0){
////        text = @"今日考试";
////    }
////    if(_delegate && [_delegate respondsToSelector:@selector(countDownContentInUserView:withInterval:)]){
////        text = [_delegate countDownContentInUserView:self withInterval:interval];
////    }
////    //倒计时字体
////    UIFont *textFont = _defont;
////    if(_delegate && [_delegate respondsToSelector:@selector(countDownContentFontInUserView:)]){
////        textFont = [_delegate countDownContentFontInUserView:self];
////    }
////    CGSize textSize = [text sizeWithFont:textFont];
////    CGRect tempFrame = lbTitle.frame;
////    tempFrame.origin.x += tempFrame.size.width;
////    CGFloat tempWidth = tempFrame.origin.x + textSize.width + __k_banner_inner_margin;//实际宽度
////    tempFrame.size.width = width > tempWidth ? textSize.width : width - tempFrame.origin.x;
//    UILabel *lbText = [[UILabel alloc] initWithFrame:tempFrame];
//    lbText.text = text;
//    lbText.font = textFont;
//    lbText.textColor = [UIColor colorWithHex:0xFE3200];
//    [cdView addSubview:lbText];
//    //倒计时面板
//    CGRect cdViewFrame = lbText.frame;
//    cdViewFrame.size.width += cdViewFrame.origin.x + __k_banner_inner_margin;
//    cdViewFrame.origin = CGPointMake(0, 0);
//    cdView.frame = cdViewFrame;
//    return cdView;
//}
@end