//
//  MoreViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MoreViewController.h"
#import "MoreMenuModel.h"
#import "MoreMenuModelCellFrame.h"
#import "MoreMenuModelTableViewCell.h"

#import "AppDelegate.h"
#import "UserAccount.h"

#import "EffectsUtils.h"
#import "UIColor+Hex.h"

#define __kMoreViewController_moreFileName @"moreSettingMenus"//主界面底部菜单文件名
#define __kMoreViewController_moreFileTypeName @"plist"//文件类型

#define __kMoreViewController_panelHeight 40//面板高度

#define __kMoreViewController_btnTop 5//顶部间隔
#define __kMoreViewController_btnLeft 15//顶部间隔
#define __kMoreViewController_btnRight 15//顶部间隔
#define __kMoreViewController_btnHeight 30//按钮高度
#define __kMoreViewController_btnbgColor 0xFF0000//

#define __kMoreViewController_cellIdentifer @"cell"//
//更多视图控制器成员变量
@interface MoreViewController (){
    NSMutableDictionary *_dataSource;
    AppDelegate *_app;
    UIColor *_btnColor;
    BOOL _isReload;
}
@end
//更多视图控制器实现
@implementation MoreViewController

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [self initWithStyle:UITableViewStyleGrouped]){
        _isReload = NO;
        _btnColor = [UIColor colorWithHex:__kMoreViewController_btnbgColor];
        _app = [[UIApplication sharedApplication] delegate];
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载数据
    [self loadData];
    //加载底部退出按钮
    [self setupBottomExitView];
}

#pragma mark 重载View将出现
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //加载底部按钮
    if(_isReload){
        _isReload = NO;
        [self setupBottomExitView];
    }
}
#pragma mark 重载View消失
-(void)viewWillDisappear:(BOOL)animated{
    _isReload = YES;
    [super viewWillDisappear:animated];
}

//加载底部退出按钮
-(void)setupBottomExitView{
    //异步线程处理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程处理底部退出按钮...");
        if(_app && _app.currentUser){//用户已登录
            CGFloat maxWidth = CGRectGetWidth(self.tableView.bounds) - __kMoreViewController_btnRight;
            CGFloat x = __kMoreViewController_btnLeft, y = __kMoreViewController_btnTop;
            //updateUI
            dispatch_async(dispatch_get_main_queue(), ^{
                //添加面板
                self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxWidth + __kMoreViewController_btnRight, __kMoreViewController_panelHeight)];
                //添加退出按钮
                UIButton *btnExit = [UIButton buttonWithType:UIButtonTypeSystem];
                btnExit.frame = CGRectMake(x, y, maxWidth - x, __kMoreViewController_btnHeight);
                [btnExit setTitle:@"退出" forState:UIControlStateNormal];
                [btnExit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btnExit addTarget:self action:@selector(btnExitClick:) forControlEvents:UIControlEventTouchUpInside];
                [EffectsUtils addBoundsRadiusWithView:btnExit BorderColor:_btnColor BackgroundColor:_btnColor];
                [self.tableView.tableFooterView addSubview:btnExit];
            });
        }else{//未登录,移除按钮
            UIView *panel = self.tableView.tableFooterView;
            if(panel){
                //updateUI
                dispatch_async(dispatch_get_main_queue(), ^{
                    //移除
                    [panel removeFromSuperview];
                });
            }
        }
    });
}

//退出登录按钮事件处理
-(void)btnExitClick:(UIButton *)sender{
    NSLog(@"退出登录按钮事件处理[%@]...", sender);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程处理退出登录问题...");
        if(_app){
            //清空
            UserAccount *ua = _app.currentUser;
            if(ua){//清除当前用户
                [ua cleanForCurrent];
                [_app changedCurrentUser:nil];
            }
            //updateUI
            dispatch_async(dispatch_get_main_queue(), ^{
                //控制器跳转
                [_app resetRootController];
            });
        }
    });
}

//加载数据
-(void)loadData{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程加载更多设置数据...");
        NSString *path = [[NSBundle mainBundle] pathForResource:__kMoreViewController_moreFileName ofType:__kMoreViewController_moreFileTypeName];
        NSLog(@"将本地资源文件[%@]加载为更多设置列表...", path);
        NSDictionary *moreSettingsDict = [NSDictionary dictionaryWithContentsOfFile:path];
        if(!moreSettingsDict || moreSettingsDict.count == 0){
            NSLog(@"没有读取到更多设置列表数据...");
            return;
        }
        //初始化数据源
        _dataSource = [NSMutableDictionary dictionaryWithCapacity:moreSettingsDict.count];
        //解析转换数据
        NSArray *keys = moreSettingsDict.allKeys;
        for(NSUInteger i = 0; i < keys.count; i++){
            NSMutableArray *frameArrays;
            NSArray *arrays = [moreSettingsDict objectForKey:[keys objectAtIndex:i]];
            if(arrays && arrays.count > 0){
                frameArrays = [NSMutableArray arrayWithCapacity:arrays.count];
                for(NSDictionary *dict in arrays){
                    if(!dict || dict.count == 0)continue;
                    MoreMenuModel *model = [[MoreMenuModel alloc] initWithDict:dict];
                    if(model && model.status){
                        MoreMenuModelCellFrame *frame = [[MoreMenuModelCellFrame alloc] init];
                        frame.model = model;
                        [frameArrays addObject:frame];
                    }
                }
                //排序
                if(frameArrays.count > 0){
                    [frameArrays sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        return ((MoreMenuModelCellFrame *)obj1).model.order - ((MoreMenuModelCellFrame *)obj2).model.order;
                    }];
                }
            }
            [_dataSource setObject:(frameArrays ? [frameArrays copy] : @[]) forKey:[NSNumber numberWithInteger:i]];
        }
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新数据列表
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
//分组数据行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataSource &&_dataSource.count > section){
        NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:section]];
        if(arrays){
            return arrays.count;
        }
    }
    return 0;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"创建行[%@]...",indexPath);
    MoreMenuModelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kMoreViewController_cellIdentifer];
    if(!cell){
        cell = [[MoreMenuModelTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:__kMoreViewController_cellIdentifer];
    }
    //加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(_dataSource && _dataSource.count > indexPath.section){
            NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:indexPath.section]];
            if(arrays && arrays.count > indexPath.row){
                MoreMenuModelCellFrame *frame = [arrays objectAtIndex:indexPath.row];
                if(frame){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //加载数据
                        [cell loadModelCellFrame:frame];
                    });
                }
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

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击行:%@...", indexPath);
    //异步线程处理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(_dataSource && _dataSource.count > indexPath.section){
            NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:indexPath.section]];
            if(arrays && arrays.count > indexPath.row){
                MoreMenuModelCellFrame *frame = [arrays objectAtIndex:indexPath.row];
                if(frame && frame.model){
                    MoreMenuModel *model = frame.model;
                    if(model.controller && model.controller.length > 0){
                        UIViewController *controller = [model buildViewController];
                        if(controller){//updateUI
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //控制器跳转
                                controller.hidesBottomBarWhenPushed = YES;
                                [self.navigationController pushViewController:controller animated:YES];
                            });
                        }
                    }
                }
            }
        }
    });
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
