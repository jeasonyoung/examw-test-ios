//
//  AccountViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AccountViewController.h"
#import "NSString+Hex.h"
#import "NSData+Hex.h"
//账号信息控制器成员变量
@interface AccountViewController ()

@end
//账号信息控制器实现类
@implementation AccountViewController
#pragma mark 程序入口
- (void)viewDidLoad {
    [super viewDidLoad];
    NSData *data = [@"FF" hexToBytes];
    
    NSLog(@"16进制-2进制=> %@",[data dataToHexString]);
    // Do any additional setup after loading the view.
}
#pragma mark 内存告急
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
