//
//  CategoryViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/15.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "CategoryViewController.h"

#import "CategoryModel.h"
#import "CategoryModelCellFrame.h"
#import "CategoryTableViewCell.h"
#import "SwitchService.h"

#import "XHRealTimeBlur.h"

#define __kCategoryViewController_title @"切换产品"//
#define __kCategoryViewController_search_height 40//查询框高度
#define __kCategoryViewController_search_placeholder @"输入考试名称"//查询框提示文字

#define __kCategoryViewController_cellIdentifierCategory @"_cellCategory"//
//考试类别控制器成员变量
@interface CategoryViewController ()<UISearchBarDelegate>{
    //数据源
    NSMutableArray *_dataSource;
    //当前页索引
    NSUInteger _pageIndex;
    //查询bar
    UISearchBar *_searchBar;
    //切换服务
    SwitchService *_service;
}
@end
//考试类别控制器实现
@implementation CategoryViewController

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kCategoryViewController_title;
    //查询Bar
    [self setupSearchBar];
    //初始化切换服务
    _service = [[SwitchService alloc]init];
    //初始化数据缓存
    _dataSource = [NSMutableArray arrayWithCapacity:_service.pageOfRows];
    //加载数据
    _pageIndex = 0;
    [self loadCategoriesWithPageIndex:_pageIndex];
}
//加载考试分类数据
-(void)loadCategoriesWithPageIndex:(NSUInteger)pageIndex{
    NSNumber *index = [NSNumber numberWithInteger:pageIndex];
    if(_service.hasCategories){
        NSLog(@"本地存在数据...");
        [self performSelectorInBackground:@selector(loadCategoriesInBackgroundWithPageIndex:) withObject:index];
    }else{
        NSLog(@"从网络下载数据...");
        [_service loadCategoriesFromNetWorks:^{
            [self loadCategoriesInBackgroundWithPageIndex:index];
        }];
    }
}
//后台线程加载考试分类数据
-(void)loadCategoriesInBackgroundWithPageIndex:(NSNumber *)pageIndex{
    NSLog(@"后台线程加载数据...");
    NSArray *arrays = [_service loadCategoriesWithPageIndex:pageIndex.integerValue];
    if(arrays && arrays.count > 0){
        NSUInteger pos = _dataSource.count;
        //初始化插入数组
        NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:arrays.count];
        for(NSUInteger i = 0; i < arrays.count; i++){
            CategoryModelCellFrame *cellFrame = [[CategoryModelCellFrame alloc]init];
            cellFrame.model = (CategoryModel *)[arrays objectAtIndex:i];
            //加载的数据追加到缓存
            [_dataSource addObject:cellFrame];
            //
            [insertIndexPaths addObject:[NSIndexPath indexPathForRow:(pos + i) inSection:0]];
        }
        //
        if(insertIndexPaths.count > 0){
            //更新UI
            [self performSelectorOnMainThread:@selector(loadEndDataOnMainUpdate:) withObject:insertIndexPaths waitUntilDone:YES];
        }
    }
}
//加载考试分类数据完成，前台更新
-(void)loadEndDataOnMainUpdate:(NSMutableArray *)insertIndexPaths{
    if(insertIndexPaths && insertIndexPaths.count > 0){
        [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma  mark 查询Bar
-(void)setupSearchBar{
    NSLog(@"setupSearchBar...");
    //初始化查询框
    CGRect searchBarFrame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), __kCategoryViewController_search_height);
    _searchBar = [[UISearchBar alloc]initWithFrame:searchBarFrame];
    _searchBar.placeholder = __kCategoryViewController_search_placeholder;
    _searchBar.showsCancelButton = YES;
    _searchBar.delegate = self;
    //添加到界面
    self.tableView.tableHeaderView = _searchBar;
}
#pragma mark 查询Bar委托UISearchBarDelegate
//获取搜索条件
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"搜索条件:%@",searchText);
    if(searchText.length == 0){
        ///TODO:重新加载考试类别数据
        return;
    }
    ///TODO:加载搜索的考试数据
}
//点击搜索按钮触发
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"点击搜索按钮出发:退下键盘,查询数据...");
    NSString *searchText = searchBar.text;
    if(searchText.length == 0){
        ///TOOD:重新加载考试类别数据
    }else{
        NSLog(@"搜索条件:%@",searchText);
        ///TODO:加载搜索的考试数据
    }
    //退下键盘
    [searchBar resignFirstResponder];
    [self.tableView disMissRealTimeBlur];
}
//点击取消按钮
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"点击取消，退下键盘...");
    ///TODO:重新加载考试类别数据
    searchBar.text = @"";
    //退下键盘
    [searchBar resignFirstResponder];
    [self.tableView disMissRealTimeBlur];
}
//点击输入框时触发
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"点击输入框，呼叫键盘...");
    //呼叫键盘
    [searchBar becomeFirstResponder];
    [self.tableView showRealTimeBlurWithBlurStyle:XHBlurStyleTranslucent];
}

#pragma mark UITableViewDataSource
//总数据量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"加载[section:%d]总数据量...", (int)section);
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//绘制每行数据UI
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"绘制行[%@]数据UI...",indexPath);
    CategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kCategoryViewController_cellIdentifierCategory];
    if(!cell){
        cell = [[CategoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:__kCategoryViewController_cellIdentifierCategory];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}

#pragma mark UITableViewDelegate
//数据行选中事件处理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"选中行[%@]...", indexPath);

    
    //[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:0] animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_dataSource && _dataSource.count > 0){
        [_dataSource removeAllObjects];
    }
}

@end
