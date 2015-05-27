//
//  PaperItemViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemViewController.h"
#import "PaperItemModel.h"
//试卷试题视图控制器成员变量
@interface PaperItemViewController (){
    //试题数据模型
    PaperItemModel *_itemModel;
    //是否显示答案
    BOOL _displayAnswer;
    //试题数据源
    NSMutableArray *_itemsDataSource;
}
@end
//试卷试题视图控制器实现
@implementation PaperItemViewController

#pragma mark 初始化
-(instancetype)initWithPaperItem:(PaperItemModel *)model andDisplayAnswer:(BOOL)display{
    if(self = [super initWithStyle:UITableViewStylePlain]){
        NSLog(@"初始化试题视图控制器[是否显示答案:%d]%@...", display, model);
        _displayAnswer = display;
        _itemModel = model;
    }
    return self;
}

#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化数据源
    _itemsDataSource = [NSMutableArray array];
    //加载试题数据
    [self loadData];
}

//加载试题数据
-(void)loadData{
    if(!_itemModel)return;
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //
       
        
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新数据
            [self.tableView reloadData];
        });
    });
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//总行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_itemsDataSource){
        return _itemsDataSource.count;
    }
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/
@end
