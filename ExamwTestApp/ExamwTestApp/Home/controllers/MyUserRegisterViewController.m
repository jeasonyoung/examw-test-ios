//
//  MyUserRegisterViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyUserRegisterViewController.h"
#import "UserRegisterModel.h"
#import "ESTextField.h"

#import "EffectsUtils.h"
#import "UIColor+Hex.h"
#import "MBProgressHUD.h"

#import "HttpUtils.h"
#import "AppConstants.h"
#import "JSONCallback.h"

#import "MyUserLoginViewController.h"

#define __kMyUserRegisterViewController_top 10//顶部间距
#define __kMyUserRegisterViewController_left 10//左边间距
#define __kMyUserRegisterViewController_bottom 10//底部间距
#define __kMyUserRegisterViewController_right 10//右边间距

#define __kMyUserRegisterViewController_textFieldHeight 30//输入框高度

#define __kMyUserRegisterViewController_marginV 10//纵向间距

//用户注册视图控制器成员变量
@interface MyUserRegisterViewController ()<UITextFieldDelegate>{
    UserRegisterModel *_userRegisterModel;
    MBProgressHUD *_waitHud;
    UIAlertView *_alertView;
}
@end
//用户注册视图控制器实现
@implementation MyUserRegisterViewController

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = @"用户注册";
    //加载文本输入框
    [self setupTextFields];
}

//加载文本输入框
-(void)setupTextFields{
    //异步线程处理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //初始化数据模型
        _userRegisterModel = [[UserRegisterModel alloc] init];
        //获取Rect
        CGRect rect = self.view.frame;
        CGFloat maxWidth = CGRectGetWidth(rect) - __kMyUserRegisterViewController_right;
        CGFloat x = __kMyUserRegisterViewController_left;
        NSArray *placeholders = @[@"请输入用户名",@"请输入密码",@"请输入重复密码",@"请输入姓名",@"请输入电子邮箱",@"请输入手机号码"];
        //NSArray *fieldNames = @[@"用户名",@"密码",@"重复密码",@"姓名",@"电子邮箱",@"手机号码"];
        //UpdateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //初始化容器panel
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:rect];
            scrollView.backgroundColor = [UIColor whiteColor];
            //添加到容器panel
            CGFloat y = __kMyUserRegisterViewController_top;
            for(NSUInteger i = 0; i < placeholders.count; i++){
                CGRect tempFrame = CGRectMake(x, (y + __kMyUserRegisterViewController_marginV),
                                              maxWidth - x, __kMyUserRegisterViewController_textFieldHeight);
                NSLog(@"ESTextField %d->%@", (int)i,NSStringFromCGRect(tempFrame));
                ESTextField *txtField = [[ESTextField alloc] initWithFrame:tempFrame];
                txtField.required = YES;
                txtField.tag = i;
                txtField.delegate = self;
                [txtField setPlaceholder:[placeholders objectAtIndex:i]];
                
//                UILabel *lbName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80,CGRectGetHeight(tempFrame))];
//                lbName.text = [fieldNames objectAtIndex:i];
//                txtField.leftView = lbName;
//                txtField.leftViewMode = UITextFieldViewModeUnlessEditing;
                
                txtField.clearButtonMode = UITextFieldViewModeWhileEditing;
                switch (i) {
                    case 1://密码
                    case 2://重复密码
                    {
                        txtField.secureTextEntry = YES;
                        break;
                    }
                    case 4:{//姓名
                        txtField.isEmailField = YES;
                        break;
                    }
                    case 5:{//手机号码
                        txtField.keyboardType = UIKeyboardTypePhonePad;
                        break;
                    }
                }
                [scrollView addSubview:txtField];
                
                y = CGRectGetMaxY(tempFrame);
            }
            //添加按钮
            UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeSystem];
            [btnSubmit setTitle:@"注册" forState:UIControlStateNormal];
            [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnSubmit.frame = CGRectMake(x, y + 2* __kMyUserRegisterViewController_marginV, maxWidth - x, __kMyUserRegisterViewController_textFieldHeight);
            [btnSubmit addTarget:self action:@selector(btnRegisterClick:) forControlEvents:UIControlEventTouchUpInside];
            UIColor *color = [UIColor colorWithHex:0x1E90FF];
            [EffectsUtils addBoundsRadiusWithView:btnSubmit BorderColor:color BackgroundColor:color];
            [scrollView addSubview:btnSubmit];
            //添加到界面
            [self.view addSubview:scrollView];
        });
    });
}

#pragma mark UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing[%@]->%d=>%@...",textField, (int)textField.tag, textField.text);
    if(![textField isKindOfClass:[ESTextField class]] || !_userRegisterModel)return;
    if((textField.tag == 2) && (![_userRegisterModel.password isEqualToString:textField.text])){
        ((ESTextField *)textField).text = @"";
        ((ESTextField *)textField).placeholder = @"密码不一致，请重新输入!";
        return;
    }
    [self loadRegisterModelValueWithInput:(ESTextField *)textField];
    
}

//注册按钮点击事件处理
-(void)btnRegisterClick:(UIButton *)sender{
    NSLog(@"按钮点击事件:%@...",sender);
    if([self validateInputInView:sender.superview]){
        //开启等待动画
        _waitHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _waitHud.color = [UIColor colorWithHex:0xD3D3D3];
        //开启异步线程提交数据
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //反馈处理
            void(^callbackShowMessage)(NSString *) = ^(NSString *msg){
                //UpdateUI
                dispatch_async(dispatch_get_main_queue(), ^{
                    //隐藏等待动画
                    if(_waitHud){ [_waitHud hide:YES];}
                    _alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [_alertView show];
                });
            };
            //NSLog(@"====>提交数据:%@......",[_userRegisterModel serialize]);
            [HttpUtils JSONDataWithUrl:_kAPP_API_REGISTER_URL
                                method:HttpUtilsMethodPOST
                            parameters:[_userRegisterModel serialize]
                              progress:nil
                               success:^(NSDictionary *callback) {
                                   NSLog(@"返回:%@",callback);
                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                       @try {
                                           JSONCallback *back = [[JSONCallback alloc] initWithDict:callback];
                                           if(back.success){//UpdateUI
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   //隐藏等待动画
                                                   if(_waitHud){ [_waitHud hide:YES];}
                                                   //跳转到登录
                                                   MyUserLoginViewController *controller = [[MyUserLoginViewController alloc] initWithAccount:_userRegisterModel.account];
                                                   [self.navigationController pushViewController:controller animated:YES];
                                               });
                                           }else{
                                               callbackShowMessage(back.msg);
                                           }
                                       }
                                       @catch (NSException *exception) {
                                           NSLog(@"反馈数据转换时发生异常:%@",exception);
                                           callbackShowMessage(exception.description);
                                       }
                                   });
                               }
                                  fail:^(NSString *err) {
                                      NSLog(@"返回:%@",err);
                                      callbackShowMessage(err);
                                  }];
        });
    }
}

//验证输入
-(BOOL)validateInputInView:(UIView*)view{
    for(UIView *subView in view.subviews){
        if ([subView isKindOfClass:[UIScrollView class]]){
            return [self validateInputInView:subView];
        }
        if ([subView isKindOfClass:[ESTextField class]]){
            if (![(MHTextField*)subView validate]){
                return NO;
            }
            [self loadRegisterModelValueWithInput:(ESTextField *)subView];
        }
    }
    return YES;
}

//赋予
-(void)loadRegisterModelValueWithInput:(ESTextField *)tf{
    if(_userRegisterModel && tf){
        NSString *value = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(value.length == 0)return;
        switch (tf.tag) {
            case 0:{//用户名
                _userRegisterModel.account = value;
                break;
            }
            case 1:{//密码
                _userRegisterModel.password = value;
                break;
            }
            case 2:{//重复密码
                break;
            }
            case 3:{//姓名
                _userRegisterModel.username = value;
                break;
            }
            case 4:{//电子邮箱
                _userRegisterModel.email = value;
                break;
            }
            case 5:{//手机号码
                _userRegisterModel.phone = value;
                break;
            }
            default:
                break;
        }
        
    }
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
