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
#import "MBProgressHUD.h"

#import "UIColor+Hex.h"

#import "SwitchService.h"

#import "AppDelegate.h"
#import "AppSettings.h"


#define __kProductViewController_title @"选择产品"//
#define __kProductViewController_cellIdentifier @"_cellProduct"//

#define __kProductViewController_alertConfirmTitle @"确定"//
#define __kProductViewController_alertCancelTitle @"取消"//

#define __kProductViewController_waitMsg @"下载试卷..."//

//产品列表控制器成员变量
@interface ProductViewController ()<UIAlertViewDelegate>{
    //所属考试ID
    NSString *_examId;
    //数据源
    NSMutableArray *_dataSource;
    //切换服务
    SwitchService *_service;
    //选中的产品
    ProductModel *_product;
    //等待动画
    MBProgressHUD *_waitHUD;
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
    //加载数据
    [self loadData];
}

//加载数据
-(void)loadData{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
            //
            if(examName && examName.length > 0){
                //主线程更新UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"前台UI更新...");
                    self.title = examName;
                    //刷新数据
                    [self.tableView reloadData];
                });
            }
        }
    });
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
    ProductModelCellFrame *cellFrame = [_dataSource objectAtIndex:indexPath.row];
    if(cellFrame && cellFrame.model){
        _product = cellFrame.model;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil
                                                           message:_product.name
                                                          delegate:self
                                                 cancelButtonTitle:__kProductViewController_alertCancelTitle
                                                 otherButtonTitles:__kProductViewController_alertConfirmTitle, nil];
        [alertView show];
    }
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"clickedButtonAtIndex==>%d", buttonIndex);
    if(buttonIndex == 1){//确认
        //等待动画
        _waitHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _waitHUD.mode = MBProgressHUDModeAnnularDeterminate;
        _waitHUD.labelText = __kProductViewController_waitMsg;
        _waitHUD.color = [UIColor colorWithHex:0xD3D3D3];
        //异步线程下载数据
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //设置产品
            if(app && app.appSettings &&_product){
                NSLog(@"设置选中的产品...");
                AppSettings *settings = app.appSettings;
                [settings setProductWithId:_product.Id andName:_product.name];
                [app updateSettings:settings];
            }
            //开始下载数据
            [_service syncDownload:^(BOOL result, NSString *msg) {
                NSLog(@"下载同步数据结果:[%d,%@]...",result,msg);
                if(result){
                    NSLog(@"更新试卷数据成功,将进行根控制器跳转...");
                    //根控制器跳转
                    if(app){[app resetRootController];}
                    return;
                }else if(msg){
                    //UpdateUI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //关闭等待动画
                        if(_waitHUD){ [_waitHUD hide:YES]; }
                        //弹出异常信息
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:msg delegate:nil
                                                                 cancelButtonTitle:__kProductViewController_alertConfirmTitle
                                                                 otherButtonTitles:nil, nil];
                        [alertView show];
                    });
                }
            }];
        });
    }
}
@end
