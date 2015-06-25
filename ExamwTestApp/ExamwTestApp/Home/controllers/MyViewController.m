//
//  MyViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyViewController.h"
#import "AppConstants.h"

#import "AppDelegate.h"
#import "AppSettings.h"
#import "UserAccount.h"

#import "UIColor+Hex.h"

#import "MyUserModelCellFrame.h"
#import "MyUserModelTableViewCell.h"

#import "MySubjectModel.h"
#import "MySubjectModelCellFrame.h"
#import "MySubjectModelTableViewCell.h"

#import "PaperService.h"

#import "MyRecordViewController.h"
#import "MyUserRegisterViewController.h"
#import "MyUserLoginViewController.h"
#import "MyProductRegViewController.h"

#define __kMyViewController_cellSectionIdentifier @"_cellSection"//
#define __kMyViewController_cellIdentifier @"_cellSubject"//
//我的视图控制器成员变量
@interface MyViewController ()<MyUserModelCellDelegate>{
    //服务
    PaperService *_service;
    //数据源
    NSMutableDictionary *_dataSource;
    //当前应用
    AppDelegate *_app;
    
    //是否重新加载
    BOOL _isReload;
}
@end
//我的视图控制器实现
@implementation MyViewController

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        //是否重新加载
        _isReload = NO;
        //初始化应用
        _app = [[UIApplication sharedApplication] delegate];
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //bar头颜色设置
    UIColor *color = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = color;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : color}];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:GLOBAL_REDCOLOR_HEX];
    //加载数据
    [self loadData];
}

//加载数据
-(void)loadData{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程加载数据...");
        //初始化数据源
        _dataSource = [NSMutableDictionary dictionaryWithCapacity:2];
        //当前用户信息
        MyUserModelCellFrame *userFrame = [[MyUserModelCellFrame alloc] init];
        userFrame.model = (_app ? _app.currentUser : nil);
        //添加到数据源
        [_dataSource setObject:@[userFrame] forKey:@0];
        //初始化服务
        if(!_service){
            NSLog(@"初始化服务...");
            _service = [[PaperService alloc] init];
        }
        //
        NSArray *records = [_service totalPaperRecords];
        if(records && records.count > 0){
            NSMutableArray *arrays = [NSMutableArray arrayWithCapacity:records.count];
            for(MySubjectModel *model in records){
                if(!model)continue;
                MySubjectModelCellFrame *frame = [[MySubjectModelCellFrame alloc] init];
                frame.model = model;
                [arrays addObject:frame];
            }
            //添加数据源
            [_dataSource setObject:[arrays copy] forKey:@1];
        }
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新数据
            [self.tableView reloadData];
        });
    });
}

#pragma mark View将进入
-(void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    if(_isReload){//重新加载数据
        _isReload = NO;
        [self loadData];
    }
}
#pragma mark View将关闭
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
//分组下的数据数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataSource && _dataSource.count > section){
        NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:section]];
        if(arrays && arrays.count > 0){
            return arrays.count;
        }
    }
    return 0;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"创建行[%@]...",indexPath);
    NSArray *arrarys = [_dataSource objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    if(arrarys > 0 && arrarys.count > indexPath.row){
        id frame = [arrarys objectAtIndex:indexPath.row];
        if([frame isKindOfClass:[MyUserModelCellFrame class]]){
            MyUserModelTableViewCell *sectionCell = [tableView dequeueReusableCellWithIdentifier:__kMyViewController_cellSectionIdentifier];
            if(!sectionCell){
                sectionCell = [[MyUserModelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                              reuseIdentifier:__kMyViewController_cellSectionIdentifier];
                sectionCell.delegate = self;
                sectionCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //加载数据
            [sectionCell loadModelCellFrame:frame];
            return sectionCell;
        }else if([frame isKindOfClass:[MySubjectModelCellFrame class]]){
            MySubjectModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kMyViewController_cellIdentifier];
            if(!cell){
                cell = [[MySubjectModelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:__kMyViewController_cellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            //加载数据
            [cell loadModelCellFrame:frame];
            return cell;
        }
    }
    return nil;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:indexPath.section]];
    if(arrays && arrays.count >  indexPath.row){
        return [[arrays objectAtIndex:indexPath.row] cellHeight];
    }
    return 0;
}
//分组名称
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section > 0){
        return @"做题记录:";
    }
    return nil;
}
#pragma mark UITableViewDelegate
//点击处理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击事件:%@", indexPath);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(indexPath.section > 0){
            NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:indexPath.section]];
            if(arrays && arrays.count > indexPath.row){
                id frame = [arrays objectAtIndex:indexPath.row];
                if(frame && [frame isKindOfClass:[MySubjectModelCellFrame class]]){
                    MySubjectModel *model = ((MySubjectModelCellFrame *)frame).model;
                    if(model && model.total > 0){
                        //updateUI
                        dispatch_async(dispatch_get_main_queue(), ^{
                            MyRecordViewController *controller = [[MyRecordViewController alloc] initWithModel:model];
                            controller.title = [NSString stringWithFormat:@"%@(%d)",model.subject, (int)model.total];
                            controller.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:controller animated:YES];
                        });
                    }
                }
            }
        }
    });
}

#pragma mark MyUserModelCellDelegate
//注册点击
-(void)userRegisterClick:(id)sender{
    NSLog(@"注册点击:%@...", sender);
    MyUserRegisterViewController *controller = [[MyUserRegisterViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}
//登录点击
-(void)userLoginClick:(id)sender{
    NSLog(@"登录点击:%@...",sender);
    MyUserLoginViewController *controller = [[MyUserLoginViewController alloc] init];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}
//变更注册码
-(void)changeRegCode:(id)sender{
    NSLog(@"变更注册码:%@...",sender);
    //MyProductRegViewController *controller = [[MyProductRegViewController alloc] init];
    //controller.hidesBottomBarWhenPushed = YES;
    //[self.navigationController pushViewController:controller animated:YES];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
