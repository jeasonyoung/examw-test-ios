//
//  AccountViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AccountViewController.h"
#import "UIViewController+VisibleView.h"
#import "UserAccountData.h"
#import "NSString+Size.h"
#import "UIColor+Hex.h"

#import "MainViewController.h"
#import "LoginViewController.h"

#define __k_account_view_margin_top 10//顶部间距
#define __k_account_view_margin_bottom 10//底部间距
#define __k_account_view_margin_left 10//左边间距
#define __k_account_view_margin_right 10//右边间距
#define __k_account_view_margin_inner 5//内部间距
#define __k_account_view_background_color 0xf4f5f9//背景色
#define __k_account_view_border_color 0xdedede//边框颜色
#define __k_account_view_border_width 0.5//边框宽度
#define __k_account_view_border_corner_radius 10//边框圆角
#define __k_account_view_label_width_per 0.3//label的宽度比例
#define __k_account_view_font_size 14.0//字体大小
#define __k_account_view_value_font_color 0x3277ec//字体颜色
#define __k_account_view_username @"用户名："//用户名
#define __k_account_view_regcodename  @"注册码："//注册码
#define __k_account_view_btn_width 70//按钮宽度
#define __k_account_view_btn_height 28//按钮高度
#define __k_account_view_btn_logout @"注销"//注销
#define __k_account_view_btn_regcode @"注册码"//注册码

#define __k_account_view_logout_alter_title @"确认"//弹出框标题
#define __k_account_view_logout_alter_message @"您是否确认注销?"//弹出框消息
#define __k_account_view_logout_alter_cancel_title @"取消"//取消按钮标题
#define __k_account_view_logout_alter_ok_title @"确认"//确认按钮标题
//账号信息控制器成员变量
@interface AccountViewController ()<UIAlertViewDelegate>
{
    UserAccountData *_userAccount;
    UIFont *_font;
}
@end
//账号信息控制器实现类
@implementation AccountViewController
#pragma mark 程序入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载当前用户信息
    _userAccount = [UserAccountData currentUser];
    //当前用户不存在或者验证不通过都弹出登录界面
    if(_userAccount == nil || ![_userAccount validation]){
        LoginViewController *lvc = [[LoginViewController alloc] init];
        [self.navigationController pushViewController:lvc animated:NO];
        //[self presentViewController:lvc animated:YES completion:nil];
        return;
    }
    //设置字体
    _font = [UIFont systemFontOfSize:__k_account_view_font_size];
    //创建用户信息
    UIView *view = [self createUserAccount];
    [self.view addSubview:view];
    
}
#pragma mark 创建用户账号信息
-(UIView *)createUserAccount{
    CGRect tempFrame = [self loadVisibleViewFrame];
    tempFrame.origin.x = __k_account_view_margin_left;
    tempFrame.origin.y += __k_account_view_margin_top;
    tempFrame.size.width -= (__k_account_view_margin_left + __k_account_view_margin_right);
    tempFrame.size.height = 100;
    
    CGFloat y = __k_account_view_margin_top,w = tempFrame.size.width;
    UIView *view = [[UIView alloc] initWithFrame:tempFrame];
    //用户名
    y = [self createTextValueWithView:view Text:__k_account_view_username Value:_userAccount.account Width:w Y:y];
    y += __k_account_view_margin_inner;
    //注册码
    y = [self createTextValueWithView:view Text:__k_account_view_regcodename Value:_userAccount.registerCode Width:w Y:y];
    y += __k_account_view_margin_top + __k_account_view_margin_inner;
    //注销按钮
    UIButton *btnLogout = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnLogout.frame = CGRectMake((w / 2) - __k_account_view_btn_width - (__k_account_view_margin_inner / 2), y, __k_account_view_btn_width, __k_account_view_btn_height);
    [self setupButtonBorder:btnLogout Title:__k_account_view_btn_logout];
    [btnLogout addTarget:self action:@selector(accountLogout:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnLogout];
    //注册码按钮
    UIButton *btnRegisterCode = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnRegisterCode.frame = CGRectMake((w / 2) + (__k_account_view_margin_inner /2), y, __k_account_view_btn_width, __k_account_view_btn_height);
    [self setupButtonBorder:btnRegisterCode Title:__k_account_view_btn_regcode];
    [btnRegisterCode addTarget:self action:@selector(accountRegisterCode:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnRegisterCode];
    //按钮高度
    y += __k_account_view_btn_height;
    //重置面板高度
    tempFrame = view.frame;
    tempFrame.size.height = y + __k_account_view_margin_bottom;
    view.frame = tempFrame;
    //设置背景色、边框和圆角
    view.backgroundColor = [UIColor colorWithHex:__k_account_view_background_color];
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [[UIColor colorWithHex:__k_account_view_border_color] CGColor];
    view.layer.borderWidth = __k_account_view_border_width;
    view.layer.cornerRadius = __k_account_view_border_corner_radius;
    return view;
}
-(void)setupButtonBorder:(UIButton *)btn Title:(NSString *)title{
    //设置按钮字体
    btn.titleLabel.font = _font;
    //设置字体颜色
    [btn setTitleColor:[UIColor colorWithHex:__k_account_view_value_font_color] forState:UIControlStateNormal];
    //设置按钮标签
    [btn setTitle:title forState:UIControlStateNormal];
    //设置按钮边框颜色
    btn.layer.borderColor = [[UIColor colorWithHex:__k_account_view_border_color] CGColor];
    //设置按钮边框宽度
    btn.layer.borderWidth = __k_account_view_border_width;
    //设置边框圆角
    btn.layer.cornerRadius = __k_account_view_border_corner_radius;
}
//创建用户信息
-(CGFloat)createTextValueWithView:(UIView *)view
                             Text:(NSString *)text
                            Value:(NSString *)value
                            Width:(CGFloat)width
                                Y:(CGFloat)y{
    
    CGSize textSize = [text sizeWithFont:_font],
        valueSize = [value sizeWithFont:_font];
    CGFloat height = textSize.height;
    if(height < valueSize.height){
        height = valueSize.height;
    }
    
    CGFloat textWidth = width * __k_account_view_label_width_per;
    UILabel *lbText = [[UILabel alloc] initWithFrame:CGRectMake(0, y + (height - textSize.height), textWidth, textSize.height)];
    lbText.font = _font;
    lbText.textAlignment = NSTextAlignmentRight;
    lbText.text = text;
    [view addSubview:lbText];
    
    UILabel *lbValue = [[UILabel alloc] initWithFrame:CGRectMake(textWidth, y + (height - valueSize.height), width - textWidth - __k_account_view_margin_right, valueSize.height)];
    lbValue.font = _font;
    lbValue.textAlignment = NSTextAlignmentLeft;
    lbValue.text = value;
    lbValue.textColor = [UIColor colorWithHex:__k_account_view_value_font_color];
    //设置下划线
    CALayer *layer = lbValue.layer;
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [[UIColor colorWithHex:__k_account_view_border_color] CGColor];
    bottomBorder.borderWidth = __k_account_view_border_width;
    bottomBorder.frame = CGRectMake(-1, layer.frame.size.height - 1, layer.frame.size.width, 1);
    [layer addSublayer:bottomBorder];
    
    [view addSubview:lbValue];
    
    y += height;
    return y;
}
//账号注销
-(void)accountLogout:(UIButton *)sender{
    //确认对话框
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:__k_account_view_logout_alter_title
                                                        message:__k_account_view_logout_alter_message
                                                       delegate:self
                                              cancelButtonTitle:__k_account_view_logout_alter_cancel_title
                                              otherButtonTitles:__k_account_view_logout_alter_ok_title, nil];
    //显示对话框
    [alterView show];
}
#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        //清空当前用户信息
        [_userAccount clean];
        //重新加载主界面
        [[[MainViewController alloc] init] gotoController];
    }
}
//注册码
-(void)accountRegisterCode:(UIButton *)sender{
    NSLog(@"accountRegisterCode...");
}
#pragma mark 内存告急
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
