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

#import "ExamModel.h"
#import "ExamModelCellFrame.h"
#import "ExamTableViewCell.h"

#import "AppConstants.h"
#import "MBProgressHUD.h"
#import "UIColor+Hex.h"

#import "SwitchService.h"

#import "ExamViewController.h"
#import "ProductViewController.h"

#define __kCategoryViewController_title @"考试分类"//
#define __kCategoryViewController_search_height 40//查询框高度
#define __kCategoryViewController_search_placeholder @"输入考试名称"//查询框提示文字

#define __kCategoryViewController_cellIdentifierCategory @"_cellCategory"//
#define __kCategoryViewController_cellIdentifierExam @"_cellExam"//
//考试类别控制器成员变量
@interface CategoryViewController ()<UISearchBarDelegate>{
    //是否搜索
    BOOL _isSearch;
    //数据源
    NSMutableArray *_dataSource;
    //查询bar
    UISearchBar *_searchBar;
    //切换服务
    SwitchService *_service;
    //下载进度条
    MBProgressHUD *_progress;
}
@end
//考试类别控制器实现
@implementation CategoryViewController

#pragma mark 重载初始化
-(instancetype)init{
    return [super initWithStyle:UITableViewStyleGrouped];
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //bar头颜色设置
    UIColor *color = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = color;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : color}];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHex:GLOBAL_REDCOLOR_HEX];
    //设置标题
    self.title = __kCategoryViewController_title;
    //查询Bar
    [self setupSearchBar];
    //初始化数据缓存
    _dataSource = [NSMutableArray array];
    //初始化切换服务
    _service = [[SwitchService alloc]init];
    //加载数据
    [self loadAllCategories];
}

//加载考试分类数据
-(void)loadAllCategories{
    _isSearch = NO;
    //加载数据到本地数据源
    void(^loadDataToDataSource)() = ^(){
        //清除数据
        if(_dataSource && _dataSource.count > 0){
            NSLog(@"清空原始数据...");
            [_dataSource removeAllObjects];
        }
        NSLog(@"后台线程加载数据...");
        NSArray *arrays = [_service loadAllCategories];
        if(arrays && arrays.count > 0){
            //初始化插入数组
            for(CategoryModel *category in arrays){
                if(!category) continue;
                CategoryModelCellFrame *cellFrame = [[CategoryModelCellFrame alloc]init];
                cellFrame.model = category;
                //加载的数据追加到缓存
                [_dataSource addObject:cellFrame];
            }
            //更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"刷新数据显示UI...");
                if(_progress && !_progress.isHidden){
                    [_progress hide:YES];
                }
                [self.tableView reloadData];
            });
        }
    };
    //
    if(_service.hasCategories){
        NSLog(@"本地存在数据...");
        //开启异步线程加载数据
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), loadDataToDataSource);
    }else{
        NSLog(@"从网络下载数据...");
        //设置等待动画
        _progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _progress.color = [UIColor colorWithHex:WAIT_HUD_COLOR];
        //开始异步线程处理
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //下载数据
            [_service loadCategoriesFromNetWorks:^(NSString *msg) {
                if(msg && msg.length > 0){//前台UpdateUI
                    NSLog(@"更新下载消息>>>%@",msg);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _progress.labelText = msg;
                    });
                }
                //加载考试分类数据到本地数据缓存
                loadDataToDataSource();
            }];
            
        });
    }
}
//加载搜索数据
-(void)loadSearchDataWithSearcName:(NSString *)searchName{
    NSLog(@"加载搜索数据:%@",searchName);
    
    //更新刷新UI
    void(^reloadRefreshView)() = ^(){
        NSLog(@"刷新数据显示UI...");
        if(_progress && !_progress.isHidden){
            [_progress hide:YES];
        }
        [self.tableView reloadData];
    };
    
    //异步处理清除数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(_dataSource && _dataSource.count > 0){
            NSLog(@"清除数据源数据...");
            [_dataSource removeAllObjects];
            //更新UI
            dispatch_async(dispatch_get_main_queue(),reloadRefreshView);
        }
    });
    
    //查询数据
    if(searchName && searchName.length > 0){
        //异步线程查询数据
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"后台搜索考试:%@",searchName);
            [_service findSearchExamsWithName:searchName resultBlock:^(ExamModel * exam) {
                if(!exam)return;
                ExamModelCellFrame *cellFrame = [[ExamModelCellFrame alloc]init];
                cellFrame.model = exam;
                [_dataSource addObject:cellFrame];
                //更新UI
                dispatch_async(dispatch_get_main_queue(),reloadRefreshView);
            }];
        });
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
//点击搜索按钮触发
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"点击搜索按钮出发:退下键盘,查询数据...");
    NSString *searchText = searchBar.text;
    if(searchText.length == 0){
        //加载数据
        [self loadAllCategories];
    }else{
        NSLog(@"搜索条件:%@",searchText);
        [self loadSearchDataWithSearcName:searchText];
    }
    //退下键盘
    [searchBar resignFirstResponder];
}
//点击取消按钮
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"点击取消，退下键盘...");
    _isSearch = NO;
    //加载数据
    [self loadAllCategories];
    //
    searchBar.text = @"";
    //退下键盘
    [searchBar resignFirstResponder];
}
//点击输入框时触发
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"点击输入框，呼叫键盘...");
    _isSearch = YES;
    //呼叫键盘
    [searchBar becomeFirstResponder];
}
//按字符查询
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"searchBar...%@", searchText);
    [self loadSearchDataWithSearcName:searchText];
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
    NSLog(@"绘制行[%@][_isSearch:%d]数据UI...",indexPath,_isSearch);
    if(_isSearch){//搜索考试
        ExamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kCategoryViewController_cellIdentifierExam];
        if(!cell){
            cell = [[ExamTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:__kCategoryViewController_cellIdentifierExam];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
        return cell;
        
    }else{//加载考试分类
        CategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kCategoryViewController_cellIdentifierCategory];
        if(!cell){
            cell = [[CategoryTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:__kCategoryViewController_cellIdentifierCategory];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
        return cell;
    }
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}

#pragma mark UITableViewDelegate
//数据行选中事件处理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"选中行[%@]...", indexPath);
    if(_isSearch){
        NSLog(@"搜索考试...");
        ExamModelCellFrame *cellFrame = [_dataSource objectAtIndex:indexPath.row];
        if(cellFrame && cellFrame.model){
            ProductViewController *productController = [[ProductViewController alloc] initWithExamModel:cellFrame.model];
            [self.navigationController pushViewController:productController animated:YES];
        }
    }else{
        NSLog(@"选中考试分类...");
        CategoryModelCellFrame *cellFrame = [_dataSource objectAtIndex:indexPath.row];
        if(cellFrame && cellFrame.model){
            ExamViewController *examController = [[ExamViewController alloc]initWithCategoryId:cellFrame.model.Id];
            [self.navigationController pushViewController:examController animated:YES];
        }
    }
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_dataSource && _dataSource.count > 0){
        [_dataSource removeAllObjects];
    }
}
@end
