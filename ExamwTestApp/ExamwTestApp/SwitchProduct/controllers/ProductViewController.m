//
//  ProductViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ProductViewController.h"

#import "ProductModel.h"
#import "ProductModelCellFrame.h"
#import "ProductTableViewCell.h"

#import "SwitchService.h"

#define __kProductViewController_title @"选择产品"//
#define __kProductViewController_cellIdentifier @"_cellProduct"//

//产品列表控制器成员变量
@interface ProductViewController (){
    //所属考试ID
    NSString *_examId;
    //数据源
    NSMutableArray *_dataSource;
    //切换服务
    SwitchService *_service;
}
@end
//产品列表控制器实现
@implementation ProductViewController

#pragma mark 初始化
-(instancetype)initWithExamId:(NSString *)examId{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        _examId = examId;
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kProductViewController_title;
    //初始化数据源
    _dataSource = [NSMutableArray array];
    //初始化服务
    _service = [[SwitchService alloc]init];
    //异步加载数据
    [self performSelectorInBackground:@selector(loadDataInBackground) withObject:nil];
}

//后台线程加载数据
-(void)loadDataInBackground{
    NSLog(@"后台线程加载数据...");
    NSString *examName;
    NSArray *arrays = [_service loadProductsWithExamId:_examId outExamName:&examName];
    if(arrays && arrays.count > 0){
        for(ProductModel *p in arrays){
            if(!p) continue;
            ProductModelCellFrame *cellFrame = [[ProductModelCellFrame alloc]init];
            cellFrame.model = p;
            [_dataSource addObject:cellFrame];
        }
    }
    //updateUI
    [self performSelectorOnMainThread:@selector(loadEndDataOnMainUpdateWithTitle:) withObject:examName waitUntilDone:YES];
}
//加载完毕主线程UpdateUI
//前台UI更新
-(void)loadEndDataOnMainUpdateWithTitle:(NSString *)title{
    NSLog(@"前台UI更新...");
    //考试分类名称
    if(title && title.length > 0){
        self.title = title;
    }
    //刷新数据
    [self.tableView reloadData];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_dataSource && _dataSource.count > 0){
        [_dataSource removeAllObjects];
    }
}

#pragma mark - Table view data source
//总数据量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//绘制行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"绘制行[%@]...", indexPath);
    ProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kProductViewController_cellIdentifier];
    if(!cell){
        cell = [[ProductTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:__kProductViewController_cellIdentifier];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //加载数据
    [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
    //
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"获取[%@]行高...", indexPath);
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}
//选中行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"选中行:%@...", indexPath);
}

@end
