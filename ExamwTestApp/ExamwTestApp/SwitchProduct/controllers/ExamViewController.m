//
//  ExamViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ExamViewController.h"
#import "SwitchService.h"

#import "ExamModel.h"
#import "ExamModelCellFrame.h"
#import "ExamTableViewCell.h"

#import "ProductViewController.h"

#define __kExamViewController_title @"选择考试"
#define __kExamViewController_cellIdentifier @"_cell_exam"

//考试控制器成员变量
@interface ExamViewController (){
    //考试分类ID
    NSString *_categoryId;
    //切换服务
    SwitchService *_service;
    //数据源
    NSMutableArray *_dataSource;
}
@end
//考试控制器实现
@implementation ExamViewController
#pragma mark 初始化
-(instancetype)initWithCategoryId:(NSString *)categoryId{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        _categoryId = categoryId;
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kExamViewController_title;
    //初始化数据源
    _dataSource = [NSMutableArray array];
    //初始化服务
    _service = [[SwitchService alloc]init];
    //加载数据
    [self loadData];
}

//加载数据
-(void)loadData{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"后台线程加载数据...");
        NSString *categoryName;
        NSArray *arrays = [_service loadExamsWithCategoryId:_categoryId outCategoryName:&categoryName];
        if(arrays && arrays.count > 0){
            for(NSUInteger i = 0; i < arrays.count; i++){
                ExamModelCellFrame *cellFrame = [[ExamModelCellFrame alloc]init];
                cellFrame.model = (ExamModel *)[arrays objectAtIndex:i];
                [_dataSource addObject:cellFrame];
            }
        }
        //
        if(categoryName && categoryName.length > 0){
            dispatch_async(dispatch_get_main_queue(), ^{//前台UI更新
                NSLog(@"前台UI更新...");
                //考试分类名称
                self.title = categoryName;
                //刷新数据
                [self.tableView reloadData];
            });
        }
    });
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"内存告警,释放数据源...");
    if(_dataSource && _dataSource.count > 0){
        [_dataSource removeAllObjects];
    }
}

#pragma mark - Table view data source
//数据量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"加载数据量...");
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//创建数据行
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"开始创建数据行:%@...",indexPath);
    ExamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kExamViewController_cellIdentifier];
    if(!cell){
        cell = [[ExamTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:__kExamViewController_cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSLog(@"创建行...");
    }
    //加载数据
    [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}
//选中行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"选中行[%@]...", indexPath);
    ExamModelCellFrame *cellFrame = [_dataSource objectAtIndex:indexPath.row];
    if(cellFrame && cellFrame.model){
        //控制器跳转
        ProductViewController *p = [[ProductViewController alloc] initWithExamModel:cellFrame.model];
        [self.navigationController pushViewController:p animated:YES];
    }
}
@end
