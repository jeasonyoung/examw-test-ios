//
//  ChoiceSubjectViewController.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/16.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SubjectViewController.h"
#import "AppDelegate.h"
#import "AppSettings.h"

#import "AppConstants.h"
#import "UIColor+Hex.h"

#import "PaperService.h"
#import "SubjectModel.h"
#import "SubjectModelCellFrame.h"
#import "SubjectTableViewCell.h"

#import "PaperListController.h"

#define __kSubjectViewController_cellIdentifer @"cell"//
//考试科目控制器成员变量
@interface SubjectViewController (){
    NSMutableArray *_dataSource;
    PaperService *_service;
}
@end
//考试科目控制器实现
@implementation SubjectViewController

#pragma mark 重置初始化
-(instancetype)init{
    return [self initWithStyle:UITableViewStyleGrouped];
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
    [self setupTitle];
    //初始化数据源
    _dataSource = [NSMutableArray array];
    //加载数据
    [self loadData];
}
//设置标题
-(void)setupTitle{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //设置考试名称
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        if(app && app.appSettings){
            //产品名称
            NSString *productName = app.appSettings.productName;
            UIFont *font = [AppConstants globalListFont];
            CGSize titleSize = [productName boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 20, CGFLOAT_MAX)
                                                         options:STR_SIZE_OPTIONS
                                                      attributes:@{NSFontAttributeName : font}
                                                         context:nil].size;
            //updateUI
            dispatch_async(dispatch_get_main_queue(), ^{
                UILabel *lbTitle = [[UILabel alloc] init];
                lbTitle.frame = CGRectMake(0, 0, titleSize.width, titleSize.height);
                lbTitle.font = font;
                lbTitle.textAlignment = NSTextAlignmentLeft;
                lbTitle.numberOfLines = 0;
                lbTitle.text = productName;
                lbTitle.textColor = [UIColor whiteColor];
                
                self.navigationItem.titleView = lbTitle;
            });
        }
    });
}
//加载数据
-(void)loadData{
    //异步线程加载数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"异步线程加载数据...");
        //初始化数据服务
        if(!_service){
            _service = [[PaperService alloc] init];
        }
        //加载数据
        NSArray *arrays = [_service totalSubjects];
        if(arrays && arrays.count > 0){
            for(NSUInteger i = 0; i < arrays.count; i++){
                SubjectModelCellFrame *frame = [[SubjectModelCellFrame alloc] init];
                frame.model = [arrays objectAtIndex:i];
                [_dataSource addObject:frame];
            }
        }
        //updateUI
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新数据
            [self.tableView reloadData];
        });
    });
}

#pragma mark UITableViewDataSource
//数据行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataSource){
        return _dataSource.count;
    }
    return 0;
}
//创建行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SubjectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:__kSubjectViewController_cellIdentifer];
    if(!cell){
        cell = [[SubjectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:__kSubjectViewController_cellIdentifer];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    //加载数据
    [cell loadModelCellFrame:[_dataSource objectAtIndex:indexPath.row]];
    //
    return cell;
}
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[_dataSource objectAtIndex:indexPath.row] cellHeight];
}
#pragma mark UITableViewDelegate
//选中处理
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //异步线程处理
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"选中[%@]处理...", indexPath);
        SubjectModelCellFrame *cellFrame = [_dataSource objectAtIndex:indexPath.row];
        if(cellFrame && cellFrame.model){
            NSString *subjectCode = cellFrame.model.code;
            //updateUI
            dispatch_async(dispatch_get_main_queue(), ^{
                PaperListController *controller = [[PaperListController alloc] initWithSubjectCode:subjectCode];
                [self.navigationController pushViewController:controller animated:YES];
            });
        }
    });
}


#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
