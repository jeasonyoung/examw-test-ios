//
//  LoginViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "LoginViewController.h"
#import "LoginViewController+UserLogin.h"
#import "SettingsViewController.h"
#import "UIViewController+VisibleView.h"
#import "NSString+Size.h"

#import "LoginData.h"
#import "RegisterData.h"

#define __k_login_view_title @"用户登录"//登录窗口
#define __k_login_view_account @"用户名"//
#define __k_login_view_account_len 4//用户名长度（4-20）
#define __k_login_view_password @"密码"//
#define __k_login_view_btn_login_title @"登录"//登录标题
#define __k_login_view_btn_register_title @"注册"//注册标题

#define __k_login_view_register_margin_top 10//顶部间距
#define __k_login_view_register_margin_left 10//左边间距
#define __k_login_view_register_margin_right 10//右边间距
#define __k_login_view_register_margin_inner_max 5//
#define __k_login_view_register_margin_inner_min 2//
#define __k_login_view_register_label_height 18//label高度
#define __k_login_view_register_textfield_height 27//textfield高度
#define __k_login_view_register_font_size 13.0//注册字体
#define __k_login_view_register_account @"用户名："//用户名
#define __k_login_view_register_account_placeholder @"请输入用户名"//
#define __k_login_view_register_password @"密码："//
#define __k_login_view_register_password_placeholder @"请输入至少6位密码"//
#define __k_login_view_register_repassword @"确认密码："//
#define __k_login_view_register_repassword_placeholder @"请再输入一次"//
#define __k_login_view_register_username @"真实姓名："//
#define __k_login_view_register_username_placeholder @"请输入真实姓名"//
#define __k_login_view_register_email @"Email："//
#define __k_login_view_register_email_placeholder @"请输入电子邮箱"//
#define __k_login_view_register_phone @"手机："//
#define __k_login_view_register_phone_placeholder @"请输入本人手机号码"//
#define __k_login_view_register_btn_title @"立即注册"//
#define __k_login_view_register_title @"学员注册"//
#define __k_login_view_register_btn_height 46//提交按钮高度

#define __k_login_view_register_per 1.0//

#define __k_login_view_alter_error_account @"请输入用户名！"//
#define __k_login_view_alter_error_password @"请输入密码"//
//登录视图控制器成员变量
@interface LoginViewController ()<UITextFieldDelegate>{
    UIAlertAction *_btnLogin;
    UIFont *_regfont;
    UIView *_currentBlockPanel;
    CGFloat _offset_y;
    
    RegisterData *_registerData;
}
@end
//登录视图控制器实现类
@implementation LoginViewController
#pragma mark 函数入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置注册字体
    _regfont = [UIFont systemFontOfSize:__k_login_view_register_font_size];
    //添加左边的取消按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goToRootViewController)];
    self.navigationItem.leftBarButtonItem = leftButton;
    [self createAlterLoginViewWithMessage:nil Account:@"fw121fw41"];
    //添加注册UI
    self.navigationItem.title = __k_login_view_register_title;
    [self createRegisterPanel];
    
    //注册监视键盘消息通知
    //键盘将弹出
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //键盘将消失
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
#pragma mark 创建登录界面
-(void)createAlterLoginViewWithMessage:(NSString *)msg Account:(NSString *)account{
    UIAlertController *alterController = [UIAlertController alertControllerWithTitle:__k_login_view_title
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    //用户名
    [alterController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = __k_login_view_account;
        //添加通知，监听的用户名内容的变化
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(accountTextFieldTextDidChangeNotification:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:textField];
        if(account && account.length > 0){
            textField.text = account;
        }
    }];
    //密码
    [alterController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = __k_login_view_password;
        textField.secureTextEntry = YES;
    }];
    //注册按钮
    UIAlertAction *btnRegister = [UIAlertAction actionWithTitle:__k_login_view_btn_register_title
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *action) {//注册
                                                            //移除用户名输入框的监听
                                                            [self removeAccountTextFieldObserver];
                                                            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
                                                             NSLog(@"注册...");
                                                        }];
    //登录按钮
    _btnLogin = [UIAlertAction actionWithTitle:__k_login_view_btn_login_title
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action) {//登录
                                          //移除用户名输入框的监听
                                          [self removeAccountTextFieldObserver];
                                          //登录验证
                                          UITextField *tfAccount = [alterController.textFields objectAtIndex:0],
                                                     *tfPassword = [alterController.textFields objectAtIndex:1];
                                          LoginData *login = [[LoginData alloc] init];
                                          login.account = [tfAccount.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                          login.password = [tfPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                          if(login.account.length == 0){//账号为空
                                              [self createAlterLoginViewWithMessage:__k_login_view_alter_error_account Account:nil];
                                              return;
                                          }
                                          if(login.password.length == 0){//密码为空
                                              [self createAlterLoginViewWithMessage:__k_login_view_alter_error_password Account:login.account];
                                              return;
                                          }
                                          //验证
                                          [self authentication:login];
                                      }];
    _btnLogin.enabled = (account && account.length > 0);
    //添加到alert
    [alterController addAction:btnRegister];
    [alterController addAction:_btnLogin];
    //弹出
    [self presentViewController:alterController animated:YES completion:nil];
}
//处理监听用户名内容的变化
-(void)accountTextFieldTextDidChangeNotification:(NSNotification *)notification{
    UITextField *tf = notification.object;
    if(tf && _btnLogin){//用户名长度
        _btnLogin.enabled = tf.text.length >= __k_login_view_account_len;
    }
}
//移除用户名输入框的监听
-(void)removeAccountTextFieldObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}
#pragma mark 跳转到根视图控制器.
-(void)goToRootViewController{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
//创建注册面板
-(void)createRegisterPanel{
    UIView *regPanel = [[UIView alloc] initWithFrame:[self loadVisibleViewFrame]];
    regPanel.backgroundColor = [UIColor clearColor];
    CGFloat x = __k_login_view_register_margin_left, y = __k_login_view_register_margin_top;
    CGFloat w = regPanel.bounds.size.width - __k_login_view_register_margin_left - __k_login_view_register_margin_right;
    //用户名
    UIView *accountView = [self createRegisterBlokPanelWithWidth:w
                                                           Title:__k_login_view_register_account
                                                     Placeholder:__k_login_view_register_account_placeholder
                                                 SecureTextEntry:NO
                                                             Tag:1
                                                    KeyboardType:UIKeyboardTypeDefault];
    CGRect tempFrame = accountView.frame;
    tempFrame.origin.x = x;
    tempFrame.origin.y = y;
    accountView.frame = tempFrame;
    [regPanel addSubview:accountView];
    y += tempFrame.size.height;
    //密码
    y += __k_login_view_register_margin_inner_max;
    UIView *pwdView = [self createRegisterBlokPanelWithWidth:w
                                                       Title:__k_login_view_register_password
                                                 Placeholder:__k_login_view_register_password_placeholder
                                             SecureTextEntry:YES
                                                         Tag:2
                                                KeyboardType:UIKeyboardTypeDefault];
    tempFrame = pwdView.frame;
    tempFrame.origin.x = x;
    tempFrame.origin.y = y;
    pwdView.frame = tempFrame;
    [regPanel addSubview:pwdView];
    y += tempFrame.size.height;
    //重复密码
    y += __k_login_view_register_margin_inner_max;
    UIView *repwdView = [self createRegisterBlokPanelWithWidth:w
                                                         Title:__k_login_view_register_repassword
                                                   Placeholder:__k_login_view_register_repassword_placeholder
                                               SecureTextEntry:YES
                                                           Tag:3
                                                  KeyboardType:UIKeyboardTypeDefault];
    tempFrame = repwdView.frame;
    tempFrame.origin.x = x;
    tempFrame.origin.y = y;
    repwdView.frame = tempFrame;
    [regPanel addSubview:repwdView];
    y += tempFrame.size.height;
    //真实姓名
    y += __k_login_view_register_margin_inner_max;
    UIView *usernameView = [self createRegisterBlokPanelWithWidth:w
                                                            Title:__k_login_view_register_username
                                                      Placeholder:__k_login_view_register_username_placeholder
                                                  SecureTextEntry:NO
                                                              Tag:4
                                                     KeyboardType:UIKeyboardTypeDefault];
    tempFrame = usernameView.frame;
    tempFrame.origin.x = x;
    tempFrame.origin.y = y;
    usernameView.frame = tempFrame;
    [regPanel addSubview:usernameView];
    y += tempFrame.size.height;
    //Email
    y += __k_login_view_register_margin_inner_max;
    UIView *emailView = [self createRegisterBlokPanelWithWidth:w
                                                         Title:__k_login_view_register_email
                                                   Placeholder:__k_login_view_register_email_placeholder
                                               SecureTextEntry:NO
                                                           Tag:5
                                                  KeyboardType:UIKeyboardTypeEmailAddress];
    tempFrame = emailView.frame;
    tempFrame.origin.x = x;
    tempFrame.origin.y = y;
    emailView.frame = tempFrame;
    [regPanel addSubview:emailView];
    y += tempFrame.size.height;
    //手机
    y += __k_login_view_register_margin_inner_max;
    UIView *phoneView = [self createRegisterBlokPanelWithWidth:w
                                                         Title:__k_login_view_register_phone
                                                   Placeholder:__k_login_view_register_phone_placeholder
                                               SecureTextEntry:NO
                                                           Tag:6
                                                  KeyboardType:UIKeyboardTypeNumberPad];
    tempFrame = phoneView.frame;
    tempFrame.origin.x = x;
    tempFrame.origin.y = y;
    phoneView.frame = tempFrame;
    [regPanel addSubview:phoneView];
    y += tempFrame.size.height;
    
    //添加提交按钮
    y += __k_login_view_register_margin_inner_max;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(x, y, w, __k_login_view_register_btn_height);
    [btn setTitle:__k_login_view_register_btn_title forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"feedback_post_normal.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"feedback_post_selected.png"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(btnRegisterClick:) forControlEvents:UIControlEventTouchUpInside];
    [regPanel addSubview:btn];
    y += __k_login_view_register_btn_height;
    
    //添加到当前视图
    y += __k_login_view_register_margin_top;
    tempFrame = regPanel.frame;
    tempFrame.size.height = y;
    regPanel.frame = tempFrame;
   // NSLog(@"panel : %@",_regPanel);
    [self.view addSubview:regPanel];
}
-(UIView *)createRegisterBlokPanelWithWidth:(CGFloat)width
                                      Title:(NSString *)title
                                Placeholder:(NSString *)placeholder
                            SecureTextEntry:(BOOL)secureTextEntry
                                        Tag:(NSInteger)tag
                               KeyboardType:(UIKeyboardType)keyboardType{
    UIView *blockPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    CGFloat y = 0;
    //label
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, y, width, __k_login_view_register_label_height)];
    lb.backgroundColor = [UIColor clearColor];
    lb.font = _regfont;
    lb.textAlignment = NSTextAlignmentLeft;
    lb.text = title;
    [blockPanel addSubview:lb];
    y += __k_login_view_register_label_height + __k_login_view_register_margin_inner_min;
    //textfield
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0, y, width, __k_login_view_register_textfield_height)];
    tf.borderStyle = UITextBorderStyleRoundedRect;//外框类型
    tf.placeholder = placeholder;//默认显示的文字
    tf.secureTextEntry = secureTextEntry;//是否以密码形式显示
    tf.font = _regfont;//字体
    tf.autocorrectionType = UITextAutocorrectionTypeNo;//设置是否启动自动提醒更正功能
    //tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    tf.returnKeyType = UIReturnKeyDone;//键盘返回类型
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;//编辑时会出现清空按钮
    tf.delegate = self;
    tf.tag = tag;
    tf.keyboardType = keyboardType;//UIKeyboardTypeDefault;//键盘类型
    tf.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;//水平对齐
    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//垂直对齐
    //tf.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应
    [blockPanel addSubview:tf];
    y += __k_login_view_register_textfield_height;
    //NSLog(@"textfield=>height:%f",tf.bounds.size.height);
    //重置高度
    CGRect tempFrame = blockPanel.frame;
    tempFrame.size.height = y;
    blockPanel.frame = tempFrame;
    
    return blockPanel;
}
//键盘将弹出
-(void)keyboardWillShow:(NSNotification *)notification{
    if(_currentBlockPanel){
        //NSLog(@"_currentBlockPanel.superview=>%@",_currentBlockPanel.superview);
        CGFloat block_panel_height = CGRectGetHeight(_currentBlockPanel.frame),
        block_panel_y = CGRectGetMaxY(_currentBlockPanel.frame);
        //取出键盘高度尺寸
        CGRect keyboardSize = [notification.userInfo [UIKeyboardFrameEndUserInfoKey] CGRectValue];
        //键盘高度
        CGFloat keyboard_height = CGRectGetHeight(keyboardSize);
        //
        _offset_y = 0;
        if(block_panel_y + (block_panel_height * __k_login_view_register_per) + keyboard_height >= CGRectGetHeight(self.view.frame)){
            CGFloat keyboard_y = CGRectGetHeight(self.view.frame) - keyboard_height;
            _offset_y = CGRectGetMaxY(_currentBlockPanel.superview.frame) -keyboard_y;
            //NSLog(@"_offset_y => %f",_offset_y);
            CGFloat duration = [notification.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            CGRect tempFrame = self.view.frame;
            tempFrame.origin.y -= _offset_y;
            [UIView animateWithDuration:duration animations:^{
                self.view.frame = tempFrame;
            }];
        }
    }
}
//键盘将隐藏
-(void)keyboardWillHide:(NSNotification *)notification{
    if(_offset_y > 0){
        CGFloat duration = [notification.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect tempFrame = self.view.frame;
        tempFrame.origin.y += _offset_y;
        [UIView animateWithDuration:duration animations:^{
            self.view.frame = tempFrame;
        }];
    }
}
#pragma mark 关闭键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];//关闭键盘
    [super touchesBegan:touches withEvent:event];
}
#pragma mark UITextFieldDelegate
//当开始点击textField会调用的方法
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    _currentBlockPanel = textField.superview;
}
//当结束编辑时调用
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textField=>%@",textField.text);
}
//按钮Done按钮的调用方法，让键盘消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
//注册按钮事件处理
-(void)btnRegisterClick:(UIButton *)sender{
    NSLog(@"btnRegisterClick=>,,,,");
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 移除消息监听
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end