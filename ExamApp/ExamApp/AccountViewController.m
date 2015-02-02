//
//  AccountViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AccountViewController.h"
#import "UserAccountData.h"
//账号信息控制器成员变量
@interface AccountViewController ()
{
    int i;
}
@end
//账号信息控制器实现类
@implementation AccountViewController
#pragma mark 程序入口
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btnLoad = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnLoad.frame = CGRectMake(20, 90, 100, 30);
    btnLoad.backgroundColor = [UIColor redColor];
    [btnLoad setTitle:@"加载数据" forState:UIControlStateNormal];
    [btnLoad addTarget:self action:@selector(btnLoadClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLoad];
    
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnSave.frame = CGRectMake(20, 200, 100, 30);
    btnSave.backgroundColor = [UIColor blueColor];
    [btnSave setTitle:@"保存数据" forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(btnSaveClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnSave];
}
-(void)btnLoadClick:(id)sender{
    UserAccountData *data = [UserAccountData currentUser];
    NSLog(@"加载数据：%@",data);
    NSLog(@"validation -> %d", [data validation]);
}

-(void)btnSaveClick:(id)sender{
    UserAccountData *account = [UserAccountData currentUser];
    if(account == nil){
        account = [[UserAccountData alloc] init];
        account.accountId = @"111-2222-333";
    }
    account.account = @"jeasonyoung";
    account.password = @"123456";
    account.registerCode = [NSString stringWithFormat:@"ABDC1212212-%d",i++];
    
    [account save];
}
#pragma mark 内存告急
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
