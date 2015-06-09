//
//  MyProductRegViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyProductRegViewController.h"
#import "MyProductRegModel.h"
#import "MyProductRegModelCellFrame.h"
#import "MyProductRegModelTableViewCell.h"

#import "AppDelegate.h"
#import "UserAccount.h"
#import "AppSettings.h"

#import "HttpUtils.h"
#import "ProductRegisterModel.h"
#import "JSONCallback.h"
#import "AppConstants.h"

#import "MBProgressHUD.h"
#import "UIColor+Hex.h"

#import "MyUserLoginViewController.h"

#define __kMyProductRegViewController_cellIdentifer @"cell"//
//产品注册视图控制器成员变量
@interface MyProductRegViewController ()<MyProductRegModelTableViewCellDelegate,UIAlertViewDelegate>{
    NSMutableArray *_dataSource;
    AppDelegate *_app;
    UIAlertView *_alertView;
    NSString *_regCode;
    MBProgressHUD *_waitHud;
}
@end
//产品注册视图控制器实现
@implementation MyProductRegViewController

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        _app = [[UIApplication sharedApplication] delegate];
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = @"产品注册码";
    //加载数据
    [self loadData];
}

//加载数据
-(void)loadData{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //数据模型
        MyProductRegModel *model = [[MyProductRegModel alloc] initWithAppSettings:(_app ? _app.appSettings : nil)];
        model.productRegCode = (_app && _app.currentUser) ? _app.currentUser.regCode : @"";
        //数据模型Frame
        MyProductRegModelCellFrame *cellFrame = [[MyProductRegModelCellFrame alloc] init];
        cellFrame.model = model;
        //添加到数据源
        _dataSource = [NSMutableArray arrayWithCapacity:1];
        [_dataSource addObject:cellFrame];
        //UpdateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新列表
            [self.tableView reloadData];
        });
    });
}

#pragma mark UITableViewDataSource
//数据总行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"创建行:%@...", indexPath);
    MyProductRegModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kMyProductRegViewController_cellIdentifer];
    if(!cell){
        cell = [[MyProductRegModelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:__kMyProductRegViewController_cellIdentifer];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //加载数据
    [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}

#pragma mark MyProductRegModelTableViewCellDelegate
//点击注册按钮
-(void)productRegCell:(MyProductRegModelTableViewCell *)cell btnClick:(UIButton *)sender regCode:(NSString *)regCode{
    _regCode = regCode;
    NSLog(@"点击注册按钮[%@]..", _regCode);
    if(!_app.currentUser){
        _alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未登录，应先登录!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [_alertView show];
    }else{
        NSString *msg = [NSString stringWithFormat:@"确认绑定注册码[%@]?", _regCode];
        _alertView = [[UIAlertView alloc] initWithTitle:@"确认" message:msg delegate:self
                                      cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [_alertView show];
    }
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{//
            MyUserLoginViewController *loginController = [[MyUserLoginViewController alloc] init];
            [self.navigationController pushViewController:loginController animated:YES];
            break;
        }
        case 1:{
            NSLog(@"准备进行服务器验证注册码...");
            [self uploadServiceValid];
            break;
        }
    }
}

//服务器验证
-(void)uploadServiceValid{
    //创建等待动画
    _waitHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _waitHud.color = [UIColor colorWithHex:WAIT_HUD_COLOR];
    //异步线程处理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程验证注册码[%@]处理...",_regCode);
        //初始化数据模型
        ProductRegisterModel *model = [[ProductRegisterModel alloc] initWithCode:_regCode];
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
        //网络处理
        [HttpUtils checkNetWorkStatus:^(BOOL statusValue) {
            if(!statusValue){
                callbackShowMessage(@"请检查网络状态!");
                return;
            }
            [HttpUtils JSONDataWithUrl:_kAPP_API_REGCODECHECK_URL method:HttpUtilsMethodPOST
                            parameters:[model serialize] progress:nil
                               success:^(NSDictionary *callback) {
                                   @try {
                                       NSLog(@"callback:%@",callback);
                                       JSONCallback *back = [[JSONCallback alloc] initWithDict:callback];
                                       if(!back.success && (back.msg && back.msg.length > 0)){
                                           callbackShowMessage(back.msg);
                                           return;
                                       }
                                       //保存注册码到本地
                                       UserAccount *ua = (_app ? _app.currentUser : nil);
                                       if(ua){
                                           [ua updateRegCode:_regCode];
                                           [_app changedCurrentUser:ua];
                                       }
                                       //UpdateUI
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           //关闭等待动画
                                           if(_waitHud){[_waitHud hide:YES];};
                                           //跳转控制器
                                           [self.navigationController popViewControllerAnimated:YES];
                                       });
                                   }
                                   @catch (NSException *exception) {
                                       NSLog(@"发生异常:%@", exception);
                                       callbackShowMessage(@"错误，请稍后重试!");
                                   }
                               } fail:^(NSString *err) {
                                   NSLog(@"callback:%@", err);
                                   callbackShowMessage(err);
                               }];
        }];
    });
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
