//
//  PaperResultViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperResultViewController.h"
#import "PaperService.h"
#import "PaperResultModel.h"
#import "PaperResultModelCellFrame.h"
#import "PaperResultTableViewCell.h"

#import "MBProgressHUD.h"
#import "UIColor+Hex.h"
#import "EffectsUtils.h"

#import "PaperViewController.h"

#define __kPaperResultViewController_title @"答题情况"//
#define __kPaperResultViewController_btnText @"查看试题"//
#define __kPaperResultViewController_cellIdentifer @"cellResult"//
//试卷结果视图控制器成员变量
@interface PaperResultViewController (){
    NSString *_paperRecordId;
    PaperService *_service;
    NSMutableDictionary *_dataSource;
    MBProgressHUD *_waitHud;
}
@end

//试卷结果视图控制器实现
@implementation PaperResultViewController

#pragma mark 初始化
-(instancetype)initWithPaperRecordId:(NSString *)recordId{
    if(self = [super initWithStyle:UITableViewStyleGrouped]){
        _paperRecordId = recordId;
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kPaperResultViewController_title;
    //
    [self setupQueryItemButtons];
    //加载数据
    [self loadData];
}

//查看试题
-(void)setupQueryItemButtons{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(0, 0, 80, 25);
    btn.center = self.tableView.tableFooterView.center;
    btn.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    [btn setTitle:__kPaperResultViewController_btnText forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [EffectsUtils addBoundsRadiusWithView:btn BorderColor:[UIColor colorWithHex:0x1E90FF] BackgroundColor:nil];
    
    [self.tableView.tableFooterView addSubview:btn];
}
//查看试题按钮事件
-(void)btnClick:(UIButton *)sender{
    NSLog(@"查看试题按钮...");
    PaperViewController *controller = nil;
    NSArray *arrays = self.navigationController.viewControllers;
    if(arrays && arrays.count > 0){
        for(UIViewController *vc in arrays){
            if(vc && [vc isKindOfClass:[PaperViewController class]]){
                controller = (PaperViewController *)vc;
                controller.displayAnswer = YES;
                break;
            }
        }
    }
    if(!controller){
        controller = [[PaperViewController alloc] initWithDisplayAnswer:YES];
        controller.delegate = self.paperViewControllerDelegate;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

//加载数据
-(void)loadData{
    if(!_paperRecordId || _paperRecordId.length == 0)return;
    //初始化等待动画
    _waitHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _waitHud.color = [UIColor colorWithHex:0xD3D3D3];
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //初始化服务
        if(!_service){
            _service = [[PaperService alloc] init];
        }
        //加载结果数据
        PaperResultModel *resultModel = [_service loadPaperResultWithPaperRecordId:_paperRecordId];
        if(resultModel){
            _dataSource = [NSMutableDictionary dictionaryWithCapacity:3];
            //1.分数
            PaperResultModelCellFrame *scoreCellFrame = [[PaperResultModelCellFrame alloc] init];
            [scoreCellFrame loadScoreWithModel:resultModel];
            [_dataSource setObject:@[scoreCellFrame] forKey:@0];
            
            //2.总题数
            PaperResultModelCellFrame *totalCellFrame = [[PaperResultModelCellFrame alloc] init];
            [totalCellFrame loadTotalWithModel:resultModel];
            //3.做对题数
            PaperResultModelCellFrame *rightCellFrame = [[PaperResultModelCellFrame alloc] init];
            [rightCellFrame loadRightsWithModel:resultModel];
            //4.做错题数
            PaperResultModelCellFrame *errorCellFrame = [[PaperResultModelCellFrame alloc] init];
            [errorCellFrame loadErrorsWithModel:resultModel];
            //5.未做题数
            PaperResultModelCellFrame *notsCellFrame = [[PaperResultModelCellFrame alloc] init];
            [notsCellFrame loadNotsWithModel:resultModel];
            [_dataSource setObject:@[totalCellFrame,rightCellFrame,errorCellFrame,notsCellFrame] forKey:@1];
            
            //6.用时
            PaperResultModelCellFrame *useTimeCellFrame = [[PaperResultModelCellFrame alloc] init];
            [useTimeCellFrame loadUseTimeWithModel:resultModel];
            //7.完成时间
            PaperResultModelCellFrame *timeCellFrame = [[PaperResultModelCellFrame alloc] init];
            [timeCellFrame loadTimeWithModel:resultModel];
            [_dataSource setObject:@[useTimeCellFrame,timeCellFrame] forKey:@2];
            
            //updateUI
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"update UI...");
                [self.tableView reloadData];
                //关闭等待动画
                if(_waitHud){
                    [_waitHud hide:YES];
                }
            });
        }
    });
}

#pragma mark UITableViewDataSource
//分组数目
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//数据行总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataSource){
        NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:section]];
        if(arrays){
            return arrays.count;
        }
    }
    return 0;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PaperResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kPaperResultViewController_cellIdentifer];
    if(!cell){
        cell = [[PaperResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:__kPaperResultViewController_cellIdentifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //异步线程处理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *arrays = [_dataSource objectForKey:[NSNumber numberWithInteger:indexPath.section]];
        if(arrays && arrays.count > indexPath.row){
            PaperResultModelCellFrame *cellFrame = [arrays objectAtIndex:indexPath.row];
            if(cellFrame){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell loadModelCellFrame:cellFrame];
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
    if(_dataSource && _dataSource.count > 0){
        [_dataSource removeAllObjects];
    }
}

@end
