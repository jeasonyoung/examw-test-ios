//
//  MyUserRegisterViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyUserRegisterViewController.h"

#import "UserRegisterModel.h"
#import "MBProgressHUD.h"
#import "UIColor+Hex.h"

#import "HttpUtils.h"
#import "AppConstants.h"
#import "JSONCallback.h"

#import "MyUserRegisterTableViewCell.h"
#import "MyUserLoginViewController.h"

#define __kMyUserRegisterViewController_cellIdentifer @"cell"

//用户注册视图控制器成员变量
@interface MyUserRegisterViewController ()<MyUserRegisterTableViewCellDelegate>{
    MBProgressHUD *_waitHud;
    UIAlertView *_alertView;
}
@end
//用户注册视图控制器实现
@implementation MyUserRegisterViewController

#pragma mark 重载初始化
-(instancetype)init{
    return [self initWithStyle:UITableViewStyleGrouped];
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = @"用户注册";
}

#pragma mark UITableViewDataSource
//数据行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"创建行:%@...", indexPath);
    MyUserRegisterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kMyUserRegisterViewController_cellIdentifer];
    if(!cell){
        cell = [[MyUserRegisterTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:__kMyUserRegisterViewController_cellIdentifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MyUserRegisterTableViewCell cellHeight];
}

#pragma mark MyUserRegisterTableViewCellDelegate
-(void)userRegisterBtnClick:(UIButton *)sender registerModel:(UserRegisterModel *)model{
    if(!model){
        NSLog(@"未获得数据模型!");
        return;
    }
    //开启等待动画
    _waitHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _waitHud.color = [UIColor colorWithHex:WAIT_HUD_COLOR];
    //开启异步线程提交数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //反馈处理
        void(^callbackShowMessage)(NSString *) = ^(NSString *msg){
            //UpdateUI
            dispatch_async(dispatch_get_main_queue(), ^{
                //隐藏等待动画
                if(_waitHud){ [_waitHud hide:YES];}
                //初始提示框
                _alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil
                                              cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                //弹出提示框
                [_alertView show];
            });
        };
        //NSLog(@"====>提交数据:%@......",[_userRegisterModel serialize]);
        [HttpUtils JSONDataWithUrl:_kAPP_API_REGISTER_URL
                            method:HttpUtilsMethodPOST
                        parameters:[model serialize]
                          progress:nil
                           success:^(NSDictionary *callback) {
                               NSLog(@"返回:%@",callback);
                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                                   @try {
                                       JSONCallback *back = [[JSONCallback alloc] initWithDict:callback];
                                       if(back.success){//UpdateUI
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               //隐藏等待动画
                                               if(_waitHud){ [_waitHud hide:YES];}
                                               //跳转到登录
                                               MyUserLoginViewController *controller = [[MyUserLoginViewController alloc] initWithAccount:model.account];
                                               [self.navigationController pushViewController:controller animated:YES];
                                           });
                                       }else{
                                           callbackShowMessage(back.msg);
                                       }
                                   }
                                   @catch (NSException *exception) {
                                       NSLog(@"反馈数据转换时发生异常:%@",exception);
                                       callbackShowMessage(@"错误，请稍后重试!");
                                   }
                               });
                           }
                              fail:^(NSString *err){
                                  NSLog(@"返回:%@",err);
                                  callbackShowMessage(err);
                              }];
    });
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
