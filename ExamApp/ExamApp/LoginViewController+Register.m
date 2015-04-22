//
//  LoginViewController+Register.m
//  ExamApp
//
//  Created by jeasonyoung on 15/2/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "LoginViewController+Register.h"
#import "UIViewController+VisibleView.h"
#import "TextFieldValidator.h"
#import "RegisterData.h"
#import "JSONCallback.h"
#import "HttpUtils.h"
#import "WaitForAnimation.h"

#define __k_login_register_font_size 13.0//注册字体
#define __k_login_register_margin_top 10//顶部间距
#define __k_login_register_margin_bottom 10//底部间距
#define __k_login_register_margin_left 10//左边间距
#define __k_login_register_margin_right 10//右边间距
#define __k_login_register_margin_inner_max 5//
#define __k_login_register_margin_inner_min 2//
#define __k_login_register_label_height 18//label高度
#define __k_login_register_textfield_height 27//textfield高度

#define __k_login_register_account_tag 1//
#define __k_login_register_account_title @"用户名："//用户名
#define __k_login_register_account_placeholder @"请输入用户名"//
#define __k_login_register_account_valid @"^.{4,20}$"//验证正则表达式
#define __k_login_register_account_valid_msg @"用户名长度只能在4~20个之间!"//

#define __k_login_register_password_tag 2//
#define __k_login_register_password_title @"密码："//
#define __k_login_register_password_placeholder @"请输入至少6位密码"//
#define __k_login_register_password_valid @"^.{6,20}$"//
#define __k_login_register_password_valid_msg @"密码长度只能在6~20个之间!"//

#define __k_login_register_repassword_tag 3//
#define __k_login_register_repassword_title @"确认密码："//
#define __k_login_register_repassword_placeholder @"请再输入一次"//
#define __k_login_register_repassword_valid_msg @"两次输入密码不相同！"//

#define __k_login_register_username_tag 4//
#define __k_login_register_username_title @"真实姓名："//
#define __k_login_register_username_placeholder @"请输入真实姓名"//
#define __k_login_register_username_valid @"^.{2,20}$"//
#define __k_login_register_username_valid_msg @"真实姓名长度只能在2~20个之间!"//

#define __k_login_register_email_tag 5//
#define __k_login_register_email_title @"Email："//
#define __k_login_register_email_placeholder @"请输入电子邮箱"//
#define __k_login_register_email_valid @"[A-Z0-9a-z._%+-]{3,}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"//
#define __k_login_register_email_valid_msg @"电子邮箱格式有误!"//

#define __k_login_register_phone_tag 6//
#define __k_login_register_phone_title @"手机："//
#define __k_login_register_phone_placeholder @"请输入本人手机号码"//
#define __k_login_register_phone_valid @"[0-9]{11,15}"//
#define __k_login_register_phone_valid_msg @"手机号码不正确！"//


#define __k_login_register_btn_title @"立即注册"//
#define __k_login_register_btn_height 46//提交按钮高度

#define __k_login_register_per 1.0//

#define __k_login_register_alter_title @"提示"//
#define __k_login_register_alter_msg @"请联网后再注册！"//
#define __k_login_register_alter_btn @"确定"//

//用户注册实现类
@implementation LoginViewController(Register)
//注册数据
RegisterData *_register;
//文本输入框集合
NSMutableArray *_textFields;
//当前输入框的y坐标/当前y的偏移
CGFloat _current_textField_y,_current_offset_y;
//注册面板
UIView *_regPanel;
//等待动画
WaitForAnimation *_regWaitHud;
#pragma mark 安装注册面板
-(void)setupRegisterPanel{
    _textFields = [NSMutableArray array];
    //字体
    UIFont *font =[UIFont systemFontOfSize:__k_login_register_font_size];
    //注册面板
    _regPanel = [[UIView alloc] initWithFrame:[self loadVisibleViewFrame]];
    CGRect regPanelFrame = _regPanel.frame;
    //坐标
    CGFloat x = __k_login_register_margin_left, y = __k_login_register_margin_top,
    w  = regPanelFrame.size.width - __k_login_register_margin_left - __k_login_register_margin_right;
    //用户名
    y = [self setupAccountWithFont:font X:x Y:y W:w];
    //密码
    y += __k_login_register_margin_inner_max;
    y = [self setupPasswordWithFont:font X:x Y:y W:w];
    //重复密码
    y += __k_login_register_margin_inner_max;
    y = [self setupRepasswordWithFont:font X:x Y:y W:w];
    //真实姓名
    y += __k_login_register_margin_inner_max;
    y = [self setupUsernameWithFont:font X:x Y:y W:w];
    //电子邮件
    y += __k_login_register_margin_inner_max;
    y = [self setupEmailWithFont:font X:x Y:y W:w];
    //手机
    y += __k_login_register_margin_inner_max;
    y = [self setupPhoneWithFont:font X:x Y:y W:w];
    //创建按钮
    y += __k_login_register_margin_inner_max;
    y = [self setupSubmitButtonWithFont:font X:x Y:y W:w];
    //重置面板高度
    regPanelFrame.size.height = y + __k_login_register_margin_bottom;
    _regPanel.frame = regPanelFrame;
    _regPanel.backgroundColor = [UIColor clearColor];
    //添加到UI
    [self.view addSubview:_regPanel];
    //注册键盘监听
    //键盘将弹出
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWilShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    //键盘讲收起
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWilHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
//提交
-(void)btnRegisterClick:(UIButton *)sender{
    NSLog(@"btnRegisterClick:==>");
    if(_textFields && _textFields.count > 0){
        //创建等待动画
        if(!_regWaitHud){
            _regWaitHud = [[WaitForAnimation alloc] initWithView:self.view WaitTitle:@"正在注册..."];
        }
        //退出输入法
        [_regPanel endEditing:YES];
        //显示等待动画
        [_regWaitHud show];
        //准备数据
        RegisterData *reg_data = [[RegisterData alloc] init];
        for(TextFieldValidator *tf in _textFields){
            if(tf){
                if(![tf validate]){//数据验证
                    //关闭等待动画
                    [_regWaitHud hide];
                    return;
                }
                [reg_data setValue:tf.text forTag:tf.tag];
            }
        }
        //提交数据
        NSLog(@"RegisterData=>%@",[reg_data serializeJSON]);
        [self registerWithUser:reg_data];
    }
}
//键盘将弹出
-(void)keyboardWilShow:(NSNotification *)notification{
    //NSLog(@"keyboardWilShow=>");
    //单个输入块的高度
    CGFloat block_panel_height = __k_login_register_margin_inner_max + __k_login_register_label_height + __k_login_register_margin_inner_min + __k_login_register_textfield_height;
    //取出键盘的高度
    CGFloat keyboard_height = CGRectGetHeight([notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]);
    _current_offset_y = 0;
    CGFloat offset = 0;
    if((offset = (_current_textField_y + (block_panel_height * __k_login_register_per) + keyboard_height - CGRectGetHeight(self.view.frame)) >= 0)){
        CGFloat keyboard_y = CGRectGetHeight(self.view.frame) - keyboard_height;
        CGFloat offsety = CGRectGetMaxY(_regPanel.frame) - keyboard_y;
        if(offsety < 0)offsety = -offsety;
        _current_offset_y = offsety - offset;
        CGFloat duration = [notification.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect tempFrame = self.view.frame;
        tempFrame.origin.y -= _current_offset_y;
        [UIView animateWithDuration:duration animations:^{
            self.view.frame = tempFrame;
        }];
    }
}
//键盘讲收起
-(void)keyboardWilHide:(NSNotification *)notification{
    //NSLog(@"keyboardWilHide=>");
    if(_current_offset_y > 0){
        CGFloat duration = [notification.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect tempFrame = self.view.frame;
        tempFrame.origin.y += _current_offset_y;
        [UIView animateWithDuration:duration animations:^{
            self.view.frame = tempFrame;
        }];
    }
}
//创建提交按钮
-(CGFloat)setupSubmitButtonWithFont:(UIFont *)font X:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(x, y, w, __k_login_register_btn_height);
    [btn setTitle:__k_login_register_btn_title forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"feedback_post_normal.png"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"feedback_post_selected.png"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(btnRegisterClick:) forControlEvents:UIControlEventTouchUpInside];
    [_regPanel addSubview:btn];
    return y += __k_login_register_btn_height;
}
//创建用户名面板
-(CGFloat)setupAccountWithFont:(UIFont *)font X:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w{
    NSNumber *ty;
    //创建用户名
    TextFieldValidator *tfAccount = [self setupAddCommonWithTitle:__k_login_register_account_title
                                                      Placeholder:__k_login_register_account_placeholder
                                                              Tag:__k_login_register_account_tag
                                                             Font:font
                                                                X:x
                                                                Y:y
                                                                W:w
                                                             OutY:&ty];
    //设置键盘
    tfAccount.keyboardType = UIKeyboardTypeDefault;
    [tfAccount updateLengthValidationMsg:__k_login_register_account_placeholder];
    NSString *validPattern = __k_login_register_account_valid;
    if(validPattern && validPattern.length > 0){
        [tfAccount addRegx:validPattern withMsg:__k_login_register_account_valid_msg];
        tfAccount.validateOnResign = YES;
    }
    return [ty floatValue];
}
//创建密码面板
-(CGFloat)setupPasswordWithFont:(UIFont *)font X:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w{
    NSNumber *ty;
    TextFieldValidator *tfPassword = [self setupAddCommonWithTitle:__k_login_register_password_title
                                                       Placeholder:__k_login_register_password_placeholder
                                                               Tag:__k_login_register_password_tag
                                                              Font:font
                                                                 X:x
                                                                 Y:y
                                                                 W:w OutY:&ty];
    //设置键盘
    tfPassword.keyboardType = UIKeyboardTypeDefault;
    tfPassword.secureTextEntry = YES;
    [tfPassword updateLengthValidationMsg:__k_login_register_password_placeholder];
    NSString *validPattern = __k_login_register_password_valid;
    if(validPattern && validPattern.length > 0){
        [tfPassword addRegx:validPattern withMsg:__k_login_register_password_valid_msg];
        tfPassword.validateOnResign = YES;
    }
    return [ty floatValue];
}
//创建重复密码面板
-(CGFloat)setupRepasswordWithFont:(UIFont *)font X:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w{
    NSNumber *ty;
    TextFieldValidator *tfRepassword = [self setupAddCommonWithTitle:__k_login_register_repassword_title
                                                         Placeholder:__k_login_register_repassword_placeholder
                                                                 Tag:__k_login_register_repassword_tag
                                                                Font:font
                                                                   X:x
                                                                   Y:y
                                                                   W:w
                                                                OutY:&ty];
    //设置键盘
    tfRepassword.keyboardType = UIKeyboardTypeDefault;
    tfRepassword.secureTextEntry = YES;
    [tfRepassword updateLengthValidationMsg:__k_login_register_repassword_placeholder];
    if(_textFields && _textFields.count >= __k_login_register_password_tag){
        TextFieldValidator *tfpwd = [_textFields objectAtIndexedSubscript:(__k_login_register_password_tag - 1)];
        if(tfpwd){
            [tfRepassword addConfirmValidationTo:tfpwd withMsg:__k_login_register_repassword_valid_msg];
        }
    }
    tfRepassword.validateOnResign = YES;
    return [ty floatValue];
}
//创建真实姓名
-(CGFloat)setupUsernameWithFont:(UIFont *)font X:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w{
    NSNumber *ty;
    TextFieldValidator *tfUsername = [self setupAddCommonWithTitle:__k_login_register_username_title
                                                       Placeholder:__k_login_register_username_placeholder
                                                               Tag:__k_login_register_username_tag
                                                              Font:font
                                                                 X:x
                                                                 Y:y
                                                                 W:w
                                                              OutY:&ty];
    //设置键盘
    tfUsername.keyboardType = UIKeyboardTypeDefault;
    [tfUsername updateLengthValidationMsg:__k_login_register_username_placeholder];
    NSString *validPattern = __k_login_register_username_valid;
    if(validPattern && validPattern.length > 0){
        [tfUsername addRegx:validPattern withMsg:__k_login_register_username_valid_msg];
        tfUsername.validateOnResign = YES;
    }
    return [ty floatValue];
}
//创建电子邮箱
-(CGFloat)setupEmailWithFont:(UIFont *)font X:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w{
    NSNumber *ty;
    TextFieldValidator *tfEmail = [self setupAddCommonWithTitle:__k_login_register_email_title
                                                    Placeholder:__k_login_register_email_placeholder
                                                            Tag:__k_login_register_email_tag
                                                           Font:font
                                                              X:x
                                                              Y:y
                                                              W:w
                                                           OutY:&ty];
    //设置键盘
    tfEmail.keyboardType = UIKeyboardTypeEmailAddress;
    [tfEmail updateLengthValidationMsg:__k_login_register_email_placeholder];
    NSString *validPattern = __k_login_register_email_valid;
    if(validPattern && validPattern.length > 0){
        [tfEmail addRegx:validPattern withMsg:__k_login_register_email_valid_msg];
        tfEmail.validateOnResign = YES;
    }
    return [ty floatValue];
}
//创建手机号码
-(CGFloat)setupPhoneWithFont:(UIFont *)font X:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w{
    NSNumber *ty;
    TextFieldValidator *tfPhone = [self setupAddCommonWithTitle:__k_login_register_phone_title
                                                    Placeholder:__k_login_register_phone_placeholder
                                                            Tag:__k_login_register_phone_tag
                                                           Font:font
                                                              X:x
                                                              Y:y
                                                              W:w
                                                           OutY:&ty];
    //设置键盘
    tfPhone.keyboardType = UIKeyboardTypeNumberPad;
    [tfPhone updateLengthValidationMsg:__k_login_register_phone_placeholder];
    NSString *validPattern = __k_login_register_phone_valid;
    if(validPattern && validPattern.length > 0){
        [tfPhone addRegx:validPattern withMsg:__k_login_register_phone_valid_msg];
        tfPhone.validateOnResign = YES;
    }
    return [ty floatValue];
}
//添加通用
-(TextFieldValidator *)setupAddCommonWithTitle:(NSString *)title
                                   Placeholder:(NSString *)placeholder
                                           Tag:(int)tag
                                          Font:(UIFont *)font
                                             X:(CGFloat)x
                                             Y:(CGFloat)y
                                             W:(CGFloat)w
                                          OutY:(NSNumber **)ty {
    //创建标签
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, __k_login_register_label_height)];
    lbTitle.backgroundColor = [UIColor clearColor];//设置背景透明
    lbTitle.font = font;
    lbTitle.textAlignment = NSTextAlignmentLeft;
    lbTitle.text = title;
    [_regPanel addSubview:lbTitle];//添加到面板
    //添加高度
    y += __k_login_register_label_height + __k_login_register_margin_inner_min;
    //输入框
    TextFieldValidator *tf = [[TextFieldValidator alloc] initWithFrame:CGRectMake(x, y, w, __k_login_register_textfield_height)];
    tf.font = font;
    tf.borderStyle = UITextBorderStyleRoundedRect;//外框类型
    tf.placeholder = placeholder;//默认显示的文字
    tf.autocorrectionType = UITextAutocorrectionTypeNo;//设置是否启动自动提醒更正功能
    tf.returnKeyType = UIReturnKeyDone;//键盘返回类型
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;//编辑时会出现清空按钮
    tf.delegate = self;
    tf.tag = tag;
    tf.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;//水平对齐
    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//垂直对齐
    //
    tf.presentInView = _regPanel;
    [_regPanel addSubview:tf];//添加到面板
    [_textFields addObject:tf];//添加到数组
    //添加高度
    y += __k_login_register_textfield_height;
    if(ty){
        *ty = [NSNumber numberWithFloat:y];
    }
    return tf;
}
#pragma mark 注册数据
-(void)registerWithUser:(RegisterData *)user{
    [HttpUtils netWorkStatus:^(BOOL statusValue) {
        if(!statusValue){//没有网络
            //关闭等待动画
            [_regWaitHud hide];
            //提示
            [self alterViewWithMessage:__k_login_register_alter_msg];
            return;
        }
        //提交数据
        AppClientSettings *appSetings = [AppClientSettings clientSettings];
        [HttpUtils JSONDataDigestWithUrl:appSetings.registerPostUrl//_kAppClientUserRegisterUrl
                                  Method:HttpUtilsMethodPOST
                              Parameters:[user serializeJSON]
                                Username:appSetings.digestUsername//_kAppClientUserName
                                Password:appSetings.digestPassword//_kAppClientPassword
                                 Success:^(NSDictionary *json) {//网路正常
                                     JSONCallback *callback = [[JSONCallback alloc] initWithDictionary:json];
                                     //关闭等待动画
                                     [_regWaitHud hide];
                                     if(!callback.success){//注册失败
                                         [self alterViewWithMessage:callback.msg];
                                         return;
                                     }
                                     //注册成功,跳转至登陆界面
                                     [self createLoginAlterWithAccount:user.account];
                                    }
                                    Fail:^(NSString *error) {//网络错误
                                        //关闭等待动画
                                        [_regWaitHud hide];
                                        //提示
                                        [self alterViewWithMessage:error];
                                        return;
                                    }];
    }];
}
//提示框
-(void)alterViewWithMessage:(NSString *)msg{
    if(!msg || msg.length == 0)return;
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:__k_login_register_alter_title
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:__k_login_register_alter_btn
                                              otherButtonTitles:nil, nil];
    [alterView show];
}
#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    _current_textField_y = CGRectGetMaxY(textField.frame);
}
//按钮Done按钮的调用方法，让键盘消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark 关闭键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];//关闭键盘
    [super touchesBegan:touches withEvent:event];
}
@end
