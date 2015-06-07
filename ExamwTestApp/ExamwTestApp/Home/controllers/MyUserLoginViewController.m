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
#import "HttpUtils.h"
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
        //检查网络
        [HttpUtils checkNetWorkStatus:^(BOOL statusValue) {
            if(!statusValue){
                //本地登录验证
                UserAccount *ua = [UserAccount accountWithUsername:account];
                if(ua){
                    if([ua validateWithPassword:pwd]){
                        //更新当前用户
                        if(_app){
                            [_app changedCurrentUser:ua];
                        }
                        //updateUI
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //关闭等待动画
                            if(_waitHud){[_waitHud hide:YES];};
                            //跳转控制器
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        });
                    }else{
                        callbackShowMessage(@"密码错误!");
                    }
                }else{
                    callbackShowMessage(@"请检查网络状态!");
                }
                return;
            }
            //初始化数据模型
            UserLoginModel *model = [[UserLoginModel alloc] initWIthAccount:account password:pwd];
            [HttpUtils JSONDataWithUrl:_kAPP_API_LOGIN_URL
                                method:HttpUtilsMethodPOST
                            parameters:[model serialize]
                              progress:nil
                               success:^(NSDictionary *callback) {
                                   //异步线程处理
                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                       @try {
                                           NSLog(@"callback:%@",callback);
                                           JSONCallback *back = [[JSONCallback alloc] initWithDict:callback];
                                           if(!back.success){
                                               callbackShowMessage(back.msg);
                                               return;
                                           }
                                           //登录成功,记录当前用户
                                           UserAccount *userAccount = [[UserAccount alloc] initWithUserId:back.data
                                                                                             withUsername:model.account];
                                           [userAccount updatePassword:model.password];
                                           if(_app){
                                               [_app changedCurrentUser:userAccount];
                                           }
                                           //updateUI
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               //关闭等待动画
                                               if(_waitHud){[_waitHud hide:YES];};
                                               //跳转控制器
                                               [self.navigationController popToRootViewControllerAnimated:YES];
                                           });
                                       }
                                       @catch (NSException *exception) {
                                           NSLog(@"发生异常:%@", exception);
                                           callbackShowMessage(@"错误，请稍后重试!");
                                       }
                                   });
                               } fail:^(NSString *err) {
                                   NSLog(@"callback:%@", err);
                                   callbackShowMessage(err);
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
