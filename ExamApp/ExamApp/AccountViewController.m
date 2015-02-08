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

#import "LoginViewController.h"
#import "AccountViewController+Logout.h"
#import "AccountViewController+RegisterCode.h"

#define __k_account_view_margin_top 10//顶部间距
#define __k_account_view_margin_bottom 10//底部间距
#define __k_account_view_margin_left 10//左边间距
#define __k_account_view_margin_right 10//右边间距
#define __k_account_view_margin_inner 10//内部最大间距

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

#define __k_account_view_observer_forkeypath @"registerCode"//
//账号信息控制器成员变量
@interface AccountViewController ()
{
    UserAccountData *_userAccount;
    UILabel *_lbRegCode;
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
        [self.navigationController pushViewController:lvc animated:nil];
        return;
    }
    //创建账号信息面板
    [self setupAccountPanel];
}
//创建账号信息面板
-(void)setupAccountPanel{
    CGFloat x = __k_account_view_margin_left,y = __k_account_view_margin_top;
    CGRect tempFrame = [self loadVisibleViewFrame];
    tempFrame.origin.x = x;
    tempFrame.origin.y += y;
    tempFrame.size.width -= (__k_account_view_margin_left + __k_account_view_margin_right);
    //
    UIView *view = [[UIView alloc] initWithFrame:tempFrame];
    //字体
    UIFont *font = [UIFont systemFontOfSize:__k_account_view_font_size];
    //高度
    NSNumber *ty;
    //宽度
    CGFloat w = CGRectGetWidth(tempFrame);
    //用户名
    [self setupTitleValueWithParent:view
                              Title:__k_account_view_username
                              Value:_userAccount.account
                               Font:font
                                  X:x
                                  Y:y
                                  W:w
                               OutY:&ty];
    //重置高度
    y = [ty floatValue];
    //注册码
    y += __k_account_view_margin_inner;
    _lbRegCode = [self setupTitleValueWithParent:view
                                                   Title:__k_account_view_regcodename
                                                   Value:_userAccount.registerCode
                                                    Font:font
                                                       X:x
                                                       Y:y
                                                       W:w
                                                    OutY:&ty];
    //添加KVO
    [_userAccount addObserver:self
                   forKeyPath:__k_account_view_observer_forkeypath
                      options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                      context:nil];
    //重置高度
    y = [ty floatValue];
    //添加按钮
    y += __k_account_view_margin_inner;
    //1.添加取消按钮
    UIButton *btnLogout = [self setupButtonWithParent:view
                                                Title:__k_account_view_btn_logout
                                                 Font:font
                                                    X:((w / 2) - __k_account_view_btn_width - (__k_account_view_margin_inner / 2))
                                                    Y:y
                                                    W:w];
    //1.1添加事件处理
    [btnLogout addTarget:self action:@selector(accountLogout:) forControlEvents:UIControlEventTouchUpInside];
    //2.添加注册码按钮
    UIButton *btnRegisterCode = [self setupButtonWithParent:view
                                                      Title:__k_account_view_btn_regcode
                                                       Font:font
                                                          X:(w / 2) + (__k_account_view_margin_inner /2)
                                                          Y:y
                                                          W:w];
    //2.1添加事件处理
    [btnRegisterCode addTarget:self action:@selector(accountRegisterCode:) forControlEvents:UIControlEventTouchUpInside];
    //添加按钮高度
    y += __k_account_view_btn_height;
    
    //重置高度
    tempFrame.size.height = y + __k_account_view_margin_bottom;
    view.frame = tempFrame;
    //设置背景色、边框和圆角
    view.backgroundColor = [UIColor colorWithHex:__k_account_view_background_color];
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [[UIColor colorWithHex:__k_account_view_border_color] CGColor];
    view.layer.borderWidth = __k_account_view_border_width;
    view.layer.cornerRadius = __k_account_view_border_corner_radius;
    //添加到面板
    [self.view addSubview:view];
}
//创建某行
-(UILabel *)setupTitleValueWithParent:(UIView *)parent
                                Title:(NSString *)title
                                Value:(NSString *)value
                                 Font:(UIFont *)font
                                    X:(CGFloat)x
                                    Y:(CGFloat)y
                                    W:(CGFloat)w
                                 OutY:(NSNumber **)ty{
    //计算文字尺寸
    CGSize titleSize = [title sizeWithFont:font],valueSize = [value sizeWithFont:font];
    //计算高度
    CGFloat height = titleSize.height;
    if(height < valueSize.height){
        height = valueSize.height;
    }
    //计算title的宽度
    CGFloat titleWidth = w * __k_account_view_label_width_per;
    //创建标题
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, y + (height - titleSize.height), titleWidth, titleSize.height)];
    lbTitle.font = font;
    lbTitle.textAlignment = NSTextAlignmentRight;
    lbTitle.text = title;
    //添加到面板
    [parent addSubview:lbTitle];
    //创建值
    UILabel *lbValue = [[UILabel alloc] initWithFrame:CGRectMake(titleWidth, y+(height-valueSize.height),w-titleWidth-__k_account_view_margin_right,valueSize.height)];
    lbValue.font = font;
    lbValue.textAlignment = NSTextAlignmentLeft;
    lbValue.text = value;
    lbValue.textColor = [UIColor colorWithHex:__k_account_view_value_font_color];
    //设置下划线
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = [[UIColor colorWithHex:__k_account_view_border_color] CGColor];
    bottomBorder.borderWidth = __k_account_view_border_width;
    CGSize layperSize = lbValue.layer.frame.size;
    bottomBorder.frame = CGRectMake(-1, layperSize.height - 1, layperSize.width, 1);
    [lbValue.layer addSublayer:bottomBorder];
    //添加到面板
    [parent addSubview:lbValue];
    //重置高度
    if(ty){
        *ty = [NSNumber numberWithFloat:(y + height)];
    }
    //返回
    return lbValue;
}
//创建按钮
-(UIButton *)setupButtonWithParent:(UIView *)parent
                             Title:(NSString *)title
                              Font:(UIFont *)font
                                 X:(CGFloat)x
                                 Y:(CGFloat)y
                                 W:(CGFloat)w{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(x, y, __k_account_view_btn_width, __k_account_view_btn_height);
    //设置按钮字体
    btn.titleLabel.font = font;
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
    //添加到面板
    [parent addSubview:btn];
    //返回对象
    return btn;
}
//注销账号
-(void)accountLogout:(UIButton *)sender{
    //NSLog(@"accountLogout==>...");
    [self logoutWithAccount:_userAccount];
}
//注册码处理
-(void)accountRegisterCode:(UIButton *)sender{
    //NSLog(@"accountRegisterCode==>...");
    [self registerWithAccount:_userAccount];
}
#pragma mark kvo处理
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:__k_account_view_observer_forkeypath]){
        _lbRegCode.text = [_userAccount valueForKey:__k_account_view_observer_forkeypath];
    }
}
#pragma mark 重载内存释放
-(void)dealloc{
    //移除观察着
    [_userAccount removeObserver:self forKeyPath:__k_account_view_observer_forkeypath];
}
#pragma mark 内存告急
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
