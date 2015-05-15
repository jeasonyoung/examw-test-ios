//
//  CategoryViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/15.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "CategoryViewController.h"

#import "XHRealTimeBlur.h"

#define __kCategoryViewController_title @"切换产品"//
#define __kCategoryViewController_search_height 40//查询框高度
#define __kCategoryViewController_search_placeholder @"输入考试名称"//查询框提示文字
//考试类别控制器成员变量
@interface CategoryViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>{
    //数据源
    NSMutableArray *_dataSource;
    //当前页索引
    NSUInteger _pageIndex;
    //查询bar
    UISearchBar *_searchBar;
    //列表控件
    UITableView *_tableView;
}
@end
//考试类别控制器实现
@implementation CategoryViewController

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kCategoryViewController_title;
    //
    //self.automaticallyAdjustsScrollViewInsets = NO;
    //查询Bar
    [self setupSearchBar];
    //TableView
    [self setupTableView];
    //layout
    [self setupLayouts];
}

#pragma  mark 查询Bar
-(void)setupSearchBar{
    NSLog(@"setupSearchBar...");
    //初始化查询框
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.placeholder = __kCategoryViewController_search_placeholder;
    _searchBar.showsCancelButton = YES;
    _searchBar.delegate = self;
    //添加到界面
    [self.view addSubview:_searchBar];
}

#pragma mark 列表TableView
-(void)setupTableView{
    NSLog(@"setup tableView...");
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    //添加到界面
    [self.view addSubview:_tableView];
}

#pragma mark 设置布局
-(void)setupLayouts{
    NSLog(@"setup layouts...");
    //
    _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    //
    NSDictionary *views = @{@"_searchBar":_searchBar,@"_tableView":_tableView};
    NSDictionary *metrics = @{@"hPadding":@2,@"vPadding":@2,@"searchHeight":@__kCategoryViewController_search_height};
    NSMutableArray *constraints = [NSMutableArray array];
    //
    NSString *hSearchBarVF = @"H:|-hPadding-[_searchBar(>=320)]-hPadding-|";
    NSArray *hSearchBarConstraints = [NSLayoutConstraint constraintsWithVisualFormat:hSearchBarVF options:0 metrics:metrics views:views];
    [constraints addObjectsFromArray:hSearchBarConstraints];
    //
    NSString *hTableViewVF = @"H:|-hPadding-[_tableView(>=320)]-hPadding-|";
    NSArray *hTableViewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:hTableViewVF options:0 metrics:metrics views:views];
    [constraints addObjectsFromArray:hTableViewConstraints];
    //
    NSString *vViewsVF = @"V:|-0-[_searchBar(searchHeight)]-vPadding-[_tableView(>=310)]-0-|";
    NSArray *vViewsConstraints = [NSLayoutConstraint constraintsWithVisualFormat:vViewsVF options:0 metrics:metrics views:views];
    [constraints addObjectsFromArray:vViewsConstraints];
    //
    [self.view addConstraints:constraints];
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
    [_tableView disMissRealTimeBlur];
}
//点击取消按钮
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"点击取消，退下键盘...");
    ///TODO:重新加载考试类别数据
    searchBar.text = @"";
    //退下键盘
    [searchBar resignFirstResponder];
    [_tableView disMissRealTimeBlur];
}
//点击输入框时触发
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"点击输入框，呼叫键盘...");
    //呼叫键盘
    [searchBar becomeFirstResponder];
    [_tableView showRealTimeBlurWithBlurStyle:XHBlurStyleTranslucent];
}

#pragma mark UITableViewDataSource
//总数据量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"加载[section:%d]总数据量...", (int)section);
    if(_dataSource){
        return _dataSource.count;
    }
    return 10;
}
//绘制每行数据UI
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"绘制行[%@]数据UI...",indexPath);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d", (int)(indexPath.row + 1)];
    return cell;
}
#pragma mark UITableViewDelegate

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_dataSource && _dataSource.count > 0){
        [_dataSource removeAllObjects];
    }
}

@end
