//
//  MyViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyViewController.h"

#import "AppDelegate.h"
#import "AppSettings.h"

#import "UserAccount.h"
#import "MyUserModelCellFrame.h"
#import "MyUserModelTableViewCell.h"

#import "MySubjectModel.h"
#import "MySubjectModelCellFrame.h"
#import "MySubjectModelTableViewCell.h"

#import "PaperService.h"

#define __kMyViewController_cellSectionIdentifier @"_cellSection"//
#define __kMyViewController_cellIdentifier @"_cellSubject"//
//我的视图控制器成员变量
@interface MyViewController ()<MyUserModelCellDelegate>{
    //数据源
    NSMutableDictionary *_dataSource;
}
@end
//我的视图控制器实现
@implementation MyViewController

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
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
        userFrame.model = [UserAccount current];
        //添加到数据源
        [_dataSource setObject:@[userFrame] forKey:@0];
        
        //当前考试代码
        NSString *examCode = [((AppDelegate *)[[UIApplication sharedApplication] delegate]).appSettings.examCode stringValue];
        //初始化服务
        static PaperService *service;
        if(!service){
            service = [[PaperService alloc] init];
        }
        //
        NSArray *records = [service totalPaperRecordsWithExamCode:examCode];
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
        id model = [arrarys objectAtIndex:indexPath.row];
        if([model isKindOfClass:[MyUserModelCellFrame class]]){
            MyUserModelTableViewCell *sectionCell = [tableView dequeueReusableCellWithIdentifier:__kMyViewController_cellSectionIdentifier];
            if(!sectionCell){
                sectionCell = [[MyUserModelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                              reuseIdentifier:__kMyViewController_cellSectionIdentifier];
                sectionCell.delegate = self;
                sectionCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //加载数据
            [sectionCell loadModelCellFrame:model];
            return sectionCell;
        }else if([model isKindOfClass:[MySubjectModelCellFrame class]]){
            MySubjectModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kMyViewController_cellIdentifier];
            if(!cell){
                cell = [[MySubjectModelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:__kMyViewController_cellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            //加载数据
            [cell loadModelCellFrame:model];
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
}

#pragma mark MyUserModelCellDelegate
//注册点击
-(void)userRegisterClick:(id)sender{
    NSLog(@"注册点击:%@...", sender);
}
//登录点击
-(void)userLoginClick:(id)sender{
    NSLog(@"登录点击:%@...",sender);
}
//变更注册码
-(void)changeRegCode:(id)sender{
    NSLog(@"变更注册码:%@...",sender);
}


#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
