//
//  MyUserLoginViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyUserLoginViewController.h"
#import "MyUserLoginTableViewCell.h"

#import "UserLoginModel.h"

#import "AppConstants.h"
#import "DigestHTTPJSONProvider.h"
#import "JSONCallback.h"

#import "AppDelegate.h"
#import "UserAccount.h"

#import "MBProgressHUD.h"
#import "UIColor+Hex.h"

#import "MyUserRegisterViewController.h"

#define __kMyUserLoginViewController_cellIdentifer @"cell"//
//用户登录视图控制器成员变量
@interface MyUserLoginViewController ()<MyUserLoginTableViewCellDelegate>{
    NSString *_account;
    AppDelegate *_app;
    MBProgressHUD *_waitHud;
    UIAlertView *_alertView;
}
@end
//用户登录视图控制器实现
@implementation MyUserLoginViewController

#pragma mark 初始化
-(instancetype)initWithAccount:(NSString *)account{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        _account = account;
        //设置当前应用
        _app = [[UIApplication sharedApplication] delegate];
    }
    return self;
}

#pragma mark 重载初始化
-(instancetype)init{
    return [self initWithAccount:nil];
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = @"用户登录";
    //设置分隔
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark UITableViewDataSource
//总行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyUserLoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kMyUserLoginViewController_cellIdentifer];
    if(!cell){
        cell = [[MyUserLoginTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:__kMyUserLoginViewController_cellIdentifer];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell loadAccount:_account];
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MyUserLoginTableViewCell cellHeight];
}

#pragma mark MyUserLoginTableViewCellDelegate
//登录点击
-(void)userLoginCell:(MyUserLoginTableViewCell *)cell loginClick:(UIButton *)sender account:(NSString *)account password:(NSString *)pwd{
    NSLog(@"登录事件处理[%@/%@]...",account,pwd);
    _waitHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _waitHud.color = [UIColor colorWithHex:WAIT_HUD_COLOR];
    //异步线程处理登录
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程处理登录验证...");
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
        //验证成功
        void(^validSuccessUpdate)(UserAccount *) = ^(UserAccount *ua){
            //更新当前用户
            if(_app && ua){
                [_app changedCurrentUser:ua];
            }
            //updateUI
            dispatch_async(dispatch_get_main_queue(), ^{
                //关闭等待动画
                if(_waitHud){[_waitHud hide:YES];};
                //跳转控制器
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        };
        
        //初始化网络操作
        DigestHTTPJSONProvider *provider = [DigestHTTPJSONProvider shareProvider];
        //检查网络
        [provider checkNetworkStatus:^(BOOL statusValue) {
            if(!statusValue){//本地验证
                UserAccount *ua = [UserAccount accountWithUsername:account];
                if(ua){
                    if([ua validateWithPassword:pwd]){
                        validSuccessUpdate(ua);
                    }else{
                        callbackShowMessage(@"密码错误!");
                    }
                }else{
                    callbackShowMessage(@"请检查网络状态!");
                }
                return;
            }
            //网络验证
            UserLoginModel *model = [[UserLoginModel alloc] initWIthAccount:account password:pwd];
            [provider postDataWithUrl:_kAPP_API_LOGIN_URL parameters:[model serialize] success:^(NSDictionary *result) {
                @try {
                    JSONCallback *callback = [[JSONCallback alloc] initWithDict:result];
                    if(!callback.success){
                        callbackShowMessage(callback.msg);
                        return;
                    }
                    //登录成功,记录当前用户
                    UserAccount *userAccount = [[UserAccount alloc] initWithUserId:callback.data
                                                                      withUsername:model.account];
                    [userAccount updatePassword:model.password];
                    //updateUI
                    validSuccessUpdate(userAccount);
                }
                @catch (NSException *exception) {
                    NSLog(@"发生异常:%@", exception);
                    callbackShowMessage(@"错误，请稍后重试!");
                }
            } fail:^(NSString *err) {
                NSLog(@"验证失败:%@", err);
                callbackShowMessage(@"服务器忙,请稍后再试!");
            }];
        }];
    });
}
//注册点击
-(void)userLoginCell:(MyUserLoginTableViewCell *)cell registerClick:(UIButton *)sender{
    NSLog(@"注册按钮点击...");
    MyUserRegisterViewController *registerController = [[MyUserRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerController animated:YES];
}


#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
