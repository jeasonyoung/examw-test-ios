//
//  AboutViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AboutViewController.h"
#import "AppDelegate.h"
#import "AppSettings.h"
#import "UserAccount.h"
#import "AppConstants.h"

#import "TitleModel.h"
#import "TitleModelCellFrame.h"
#import "TitleTableViewCell.h"

#define __kAboutViewController_title @"关于应用"//

#define __kAboutViewController_cellIdentifer @"cell"//
//关于视图控制器成员变量
@interface AboutViewController (){
    AppDelegate *_app;
    BOOL _isReload;
    NSMutableDictionary *_dataSource;
}
@end
//关于视图控制器实现
@implementation AboutViewController

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        _isReload = NO;
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kAboutViewController_title;
    //加载数据
    [self loadData];
}

//加载数据
-(void)loadData{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //初始化数据源
        _dataSource = [NSMutableDictionary dictionary];
        //APP名称
        NSString *appTitle = [NSString stringWithFormat:__kAPP_NAME,__kAPP_VER];
        TitleModelCellFrame *appFrame = [[TitleModelCellFrame alloc] init];
        appFrame.model = [[TitleModel alloc] initWithTitle:appTitle];
        //添加到数据源
        [_dataSource setObject:@[appFrame] forKey:@0];
        
        //应用设置
        AppSettings *settings = _app.appSettings;
        if(settings){
            //考试名称
            NSString *examTitle = [NSString stringWithFormat:@"所属考试:%@", settings.examName];
            TitleModelCellFrame *examFrame = [[TitleModelCellFrame alloc] init];
            examFrame.model = [[TitleModel alloc] initWithTitle:examTitle];
            //产品名称
            NSString *productTitle = [NSString stringWithFormat:@"所属产品:%@", settings.productName];
            TitleModelCellFrame *productFrame = [[TitleModelCellFrame alloc] init];
            productFrame.model = [[TitleModel alloc] initWithTitle:productTitle];
            //添加到数据源
            [_dataSource setObject:@[examFrame,productFrame] forKey:@1];
        }
        
        UserAccount *ua = _app.currentUser;
        if(ua){
            //产品注册码
            NSString *regCodeTitle = [NSString stringWithFormat:@"产品注册码:%@", ua.regCode];
            TitleModelCellFrame *regCodeFrame = [[TitleModelCellFrame alloc] init];
            regCodeFrame.model = [[TitleModel alloc] initWithTitle:regCodeTitle];
            
            //当前用户
            NSString *usernameTitle = [NSString stringWithFormat:@"当前用户:%@", ua.username];
            TitleModelCellFrame *usernameFrame = [[TitleModelCellFrame alloc] init];
            usernameFrame.model = [[TitleModel alloc] initWithTitle:usernameTitle];
            
            //添加到数据源
            [_dataSource  setObject:@[regCodeFrame,usernameFrame] forKey:@2];
        }
        
        
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新列表数据
            [self.tableView reloadData];
        });
    });
}

#pragma mark 视图将呈现
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(_isReload){
        _isReload = NO;
        [self loadData];
    }
}

#pragma mark 视图将关闭
-(void)viewWillDisappear:(BOOL)animated{
    _isReload = YES;
    [super viewWillDisappear:animated];
}

#pragma mark UITableViewDataSource
//分组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//分组数据数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataSource && _dataSource.count > section){
        NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:section]];
        if(arrays){
            return arrays.count;
        }
    }
    return 0;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"创建数据行[%@]...", indexPath);
    TitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kAboutViewController_cellIdentifer];
    if(!cell){
        cell = [[TitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                         reuseIdentifier:__kAboutViewController_cellIdentifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //异步加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(_dataSource && _dataSource.count > indexPath.section){
            NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:indexPath.section]];
            if(arrays && arrays.count > indexPath.row){
                //updateUI
                dispatch_async(dispatch_get_main_queue(), ^{
                    //加载数据
                    [cell loadModelCellFrame:[arrays objectAtIndex:indexPath.row]];
                });
            }
        }
    });
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataSource && _dataSource.count > indexPath.section){
        NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        if(arrays && arrays.count > indexPath.row){
            return [[arrays objectAtIndex:indexPath.row] cellHeight];
        }
    }
    return 0;
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
