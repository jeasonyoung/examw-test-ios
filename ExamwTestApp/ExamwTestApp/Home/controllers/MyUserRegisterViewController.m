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

#define __kMyUserRegisterViewController_top 10//顶部间距
#define __kMyUserRegisterViewController_left 10//左边间距
#define __kMyUserRegisterViewController_bottom 10//底部间距
#define __kMyUserRegisterViewController_right 10//右边间距

#define __kMyUserRegisterViewController_textFieldHeight 30//输入框高度

#define __kMyUserRegisterViewController_marginV 10//纵向间距

//用户注册视图控制器成员变量
@interface MyUserRegisterViewController (){
   
}
@end
//用户注册视图控制器实现
@implementation MyUserRegisterViewController

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载文本输入框
    [self setupTextFields];
}

//加载文本输入框
-(void)setupTextFields{
    CGRect rect = self.view.frame;
    CGFloat maxWidth = CGRectGetWidth(rect) - __kMyUserRegisterViewController_right;
    CGFloat x = __kMyUserRegisterViewController_left,y = __kMyUserRegisterViewController_top;
    NSArray *textFields = @[@"account",@"password",@"repassword",@"username",@"email",@"phone"];
    NSArray *placeholders = @[@"请输入用户名",@"请输入密码",@"请输入重复密码",@"请输入姓名",@"请输入电子邮箱",@"请输入手机号码"];
        
    //UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:rect];
    scrollView.backgroundColor = [UIColor whiteColor];
    for(NSUInteger i = 0; i < placeholders.count; i++){
        CGRect tempFrame = CGRectMake(x, (y + __kMyUserRegisterViewController_marginV),
                                        maxWidth - x, __kMyUserRegisterViewController_textFieldHeight);
        NSLog(@"ESTextField %d->%@", (int)i,NSStringFromCGRect(tempFrame));
        ESTextField *txtField = [[ESTextField alloc] initWithFrame:tempFrame];
        //[txtField setFont:font];
        txtField.required = YES;
        txtField.tag = i;
        [txtField setPlaceholder:[placeholders objectAtIndex:i]];
        if([[textFields objectAtIndex:i] isEqualToString:@"email"]){
            txtField.isEmailField = YES;
        }
        [scrollView addSubview:txtField];
        
        y = CGRectGetMaxY(tempFrame);
    }
    UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnSubmit setTitle:@"注册" forState:UIControlStateNormal];
    [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSubmit.frame = CGRectMake(x, y + 2* __kMyUserRegisterViewController_marginV, maxWidth - x, __kMyUserRegisterViewController_textFieldHeight);
    [EffectsUtils addBoundsRadiusWithView:btnSubmit BorderColor:[UIColor blueColor] BackgroundColor:[UIColor blueColor]];
    [scrollView addSubview:btnSubmit];
    [self.view addSubview:scrollView];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
