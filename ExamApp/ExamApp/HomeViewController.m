//
//  HomeController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "HomeViewController.h"
#import "NSString+Size.h"
#import "NSString+Date.h"
#import "UIColor+Hex.h"
#import "NSDate+TimeZone.h"

#define __k_banner_top 4//顶部间距
#define __k_banner_left 4//左边间距
#define __k_banner_right 4//右边间距
#define __k_banner_view_margin 5//banner内View与边框的间距
#define __k_banner_inner_margin 2 //内部间距
#define __k_banner_icon_cal_with 29 //日历图标宽度
#define __k_banner_icon_cal_height 28 //日历图标的高度
#define __k_banner_icon_user_width 25//用户图标宽度
#define __k_banner_icon_user_height 25//用户图标高度
//主页控制器成员变量
@interface HomeViewController ()
{
    //导航控制器
    UINavigationController *_navController;
}
@end
//主页控制器实现类
@implementation HomeViewController
#pragma mark 初始化重载
-(id)init{
    if(self = [super init]){
        //初始化导航控制器，并将当前控制器设为根控制器
        _navController = [[UINavigationController alloc] initWithRootViewController:self];
    }
    return self;
}
#pragma mark 加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //创建Banner头版面
    [self createUserBanner];
//    
//    UIView *userView = [self createUserViewWithName:@"jeasonyoung" font:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] Width:200];
//    userView.frame = CGRectMake(80, 66, 220, 50);
//    [self.view addSubview:userView];
    
    NSLog(@"home====");
}
#pragma mark 构建用户Banner头
-(void)createUserBanner{
    NSDate *now = [NSDate date];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    //banner头面板
    UIView *bannerView = [[UIView alloc] init];
    CGRect viewFrame = self.view.frame;
    CGFloat nav_height = self.navigationController.navigationBar.bounds.size.height;
    if(!self.prefersStatusBarHidden){
        nav_height += 20;
    }
    CGFloat x = viewFrame.origin.x + __k_banner_left, y = viewFrame.origin.y + nav_height + __k_banner_top,
    w = viewFrame.size.width - __k_banner_left * 2;//, h = 0;
     //添加日历面板
    UIView *calView = [self createCalcuateWithFont:font andCalDate:now];
    CGRect calViewTempFrame = calView.frame;
    calViewTempFrame.origin.x += __k_banner_view_margin;
    calViewTempFrame.origin.y += __k_banner_view_margin;
    calView.frame = calViewTempFrame;
    //h += calView.bounds.size.height;//叠加日历面板的高度
    [bannerView addSubview:calView];//添加到Banner面板
    NSLog(@"calView = %@", calView);
    
    //添加用户面板
    CGFloat userViewWidth = w - calView.bounds.size.width - __k_banner_view_margin;
    UIView *userView = [self createUserViewWithName:@"jeasonyoung" font:font Width:userViewWidth];
    CGRect userViewTempFrame = userView.frame;
    userViewTempFrame.origin.x = w - userViewTempFrame.size.width;
    userViewTempFrame.origin.y = __k_banner_view_margin;
    userView.frame = userViewTempFrame;
    [bannerView addSubview:userView];//添加到Banner面板
    NSLog(@"userView = %@", userView);
    
    //添加倒计时面板
    UIView *cdView = [self createCountdownWithFont:font andExamDate:[@"2015-01-25" toDateWithFormat:@"yyyy-MM-dd"] andWidth:w];
    CGRect cdViewFrame = cdView.frame;
    cdViewFrame.origin.x += __k_banner_view_margin;//x坐标
    cdViewFrame.origin.y = userView.frame.origin.y + userView.frame.size.height + (__k_banner_view_margin * 2);//y坐标
    cdView.frame = cdViewFrame;
    [bannerView addSubview:cdView];
    NSLog(@"cdView = %@", cdView);
    
    //添加到界面
    bannerView.frame = CGRectMake(x, y, w, cdView.frame.origin.y + cdView.frame.size.height + (__k_banner_view_margin * 2));
    bannerView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];
    bannerView.layer.masksToBounds = YES;
    bannerView.layer.cornerRadius = 8.5;
    bannerView.layer.borderWidth = 1.0;
    bannerView.layer.borderColor = [[UIColor colorWithHex:0xdedede] CGColor];
    
    NSLog(@"bannerView = %@", bannerView);
    [self.view addSubview:bannerView];
}
//创建日历面板
-(UIView *)createCalcuateWithFont:(UIFont *)font andCalDate:(NSDate *)cal{
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
//创建用户信息面板
-(UIView *)createUserViewWithName:(NSString *)name font:(UIFont *)font Width:(CGFloat)width {
    UIView *userView = [[UIView alloc] init];
    //用户图标
    UIImageView *iconUser = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_username.png"]];
    iconUser.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat iconHeight = (__k_banner_icon_user_height > __k_banner_icon_cal_height) ? __k_banner_icon_user_height : __k_banner_icon_cal_height;
    iconUser.frame = CGRectMake(0, (iconHeight - __k_banner_icon_user_height)/2, __k_banner_icon_user_width, __k_banner_icon_user_height);
    [userView addSubview:iconUser];
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
//创建倒计时面板
-(UIView *)createCountdownWithFont:(UIFont *)font andExamDate:(NSDate *)date andWidth:(CGFloat)width{
    UIView *cdView = [[UIView alloc] init];
    //标题
    NSString *title = @"距离考试仅剩：";
    CGSize titleSize = [title sizeWithFont:font];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleSize.width + __k_banner_inner_margin, titleSize.height)];
    lbTitle.text = title;
    lbTitle.font = font;
    [cdView addSubview:lbTitle];
    //倒计时
    int interval = [date dayIntervalSinceDate:[NSDate currentLocalTime]];
    NSString *text = interval >= 0 ? [NSString stringWithFormat:@"%d 天", (int)interval] : @"本次考试已结束";
    if(interval == 0){
        text = @"今日考试";
    }
    CGSize textSize = [text sizeWithFont:font];
    CGRect tempFrame = lbTitle.frame;
    tempFrame.origin.x += tempFrame.size.width;
    CGFloat tempWidth = tempFrame.origin.x + textSize.width + __k_banner_inner_margin;//实际宽度
    tempFrame.size.width = width > tempWidth ? textSize.width : width - tempFrame.origin.x;
    UILabel *lbText = [[UILabel alloc] initWithFrame:tempFrame];
    lbText.text = text;
    lbText.font = font;
    [cdView addSubview:lbText];
    //倒计时面板
    CGRect cdViewFrame = lbText.frame;
    cdViewFrame.size.width += cdViewFrame.origin.x + __k_banner_inner_margin;
    cdViewFrame.origin = CGPointMake(0, 0);
    cdView.frame = cdViewFrame;
    return cdView;
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end