//
//  PaperDetailsViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperDetailsViewController.h"

#import "PaperInfoModel.h"
#import "PaperModel.h"
#import "PaperStructureModel.h"

#import "PaperTitleModel.h"
#import "PaperTitleModelCellFrame.h"
#import "PaperTitleTableViewCell.h"

#import "PaperButtonModel.h"
#import "PaperButtonModelCellFrame.h"
#import "PaperButtonTableViewCell.h"

#import "PaperDetailsModel.h"
#import "PaperDetailsModelCellFrame.h"
#import "PaperDetailsTableViewCell.h"

#import "PaperService.h"

#import "MBProgressHUD.h"
#import "UIColor+Hex.h"

#define __kPaperDetailsViewController_title @"试卷详情"//
#define __kPaperDetailsViewController_cellIdentifier @"_cellDetails_%d"//
//试卷明细视图控制器成员变量
@interface PaperDetailsViewController (){
    //试卷信息数据模型
    PaperInfoModel *_infoModel;
    //试卷记录数据模型
    PaperRecordModel *_recordModel;
    //数据源
    NSMutableArray *_dataSource;
    //试卷服务
    PaperService *_service;
    //等待动画
    MBProgressHUD *_waitHud;
}
@end

//试卷明细视图控制器实现
@implementation PaperDetailsViewController

#pragma mark 初始化
-(instancetype)initWithPaperInfo:(PaperInfoModel *)model{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        _infoModel = model;
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kPaperDetailsViewController_title;
    //初始化数据源
    _dataSource = [NSMutableArray arrayWithCapacity:3];
    //初始化试卷服务
    _service = [[PaperService alloc] init];
    //开启等待动画
    _waitHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _waitHud.color = [UIColor colorWithHex:0xD3D3D3];
    //加载数据
    [self loadData];
}

//加载数据
-(void)loadData{
    //隐藏行分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //异步加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //加载数据
        PaperModel *paperModel = [_service loadPaperModelWithPaperId:_infoModel.Id];
        NSLog(@"paperModel=>%@",paperModel);
        if(paperModel && _infoModel){
            //1.标题
            PaperTitleModelCellFrame *titleModelCellFrame = [[PaperTitleModelCellFrame alloc] init];
            titleModelCellFrame.model = [[PaperTitleModel alloc]initWithTitle:paperModel.name
                                                                   andSubject:_infoModel.subject];
            [_dataSource addObject:titleModelCellFrame];
            //2.按钮
            PaperButtonModelCellFrame *btnModelCellFrame = [[PaperButtonModelCellFrame alloc] init];
            _recordModel = [_service loadNewsRecordWithPaperId:paperModel.code];
            btnModelCellFrame.model = [[PaperButtonModel alloc] initWithPaperRecord:_recordModel];
            [_dataSource addObject:btnModelCellFrame];
            //3.明细
            PaperDetailsModel *detailsModel = [[PaperDetailsModel alloc] init];
            detailsModel.desc = paperModel.desc;
            detailsModel.source = paperModel.source;
            detailsModel.area = paperModel.area;
            detailsModel.type = paperModel.type;
            detailsModel.time = paperModel.time;
            detailsModel.year = paperModel.year;
            detailsModel.total = paperModel.total;
            detailsModel.score = paperModel.score;
            PaperDetailsModelCellFrame *detailsCellFrame = [[PaperDetailsModelCellFrame alloc] init];
            detailsCellFrame.model = detailsModel;
            [_dataSource addObject:detailsCellFrame];
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                //
                [self.tableView reloadData];
                [_waitHud hide:YES];
            });
        }
    });
}

#pragma mark tableview
//加载数据量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"加载数据量...");
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"创建行...");
    
    NSString *identifier = [NSString stringWithFormat:__kPaperDetailsViewController_cellIdentifier, (int)indexPath.row];
    switch (indexPath.row) {
        case 0://标题
        {
            PaperTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if(!cell){
                NSLog(@"创建标题行...");
                cell = [[PaperTitleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //加载数据
            [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
            return cell;
        }
        case 1:{//按钮
            PaperButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if(!cell){
                NSLog(@"创建按钮行...");
                cell = [[PaperButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.btnClick = ^(NSInteger tag){
                    NSLog(@"按钮点击:>>>%d",(int)tag);
                };
            }
            //加载数据
            [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
            return cell;
        }
        case 2:{//明细
            PaperDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if(!cell){
                NSLog(@"创建明细行...");
                cell = [[PaperDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            //加载数据
            [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
            return cell;
        }
        default:
            break;
    }
    return nil;
}
//获取行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
