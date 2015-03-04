//
//  PaperListViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperListViewController.h"
#import "UIViewController+VisibleView.h"
#import "NSString+Date.h"

#import "PaperData.h"
#import "PaperService.h"
#import "WaitForAnimation.h"

#import "PaperDetailViewController.h"

#define __k_paperlist_margin_min 2//控件之间的最小间距
#define __k_paperlist_segment_margin_top 5//顶部间隔
#define __k_paperlist_segment_margin_left 20//左边间隔
#define __k_paperlist_segment_margin_right 20//右边间隔
#define __k_paperlist_segment_height 30//高度
#define __k_paperlist_segment_data @[@"历年真题",@"模拟试题",@"预测试题",@"练习题"]

#define __k_paperlist_table_cellIdentifier @"cell"
#define __k_paperlist_cell_textLabel_font_size 13//字体大小
#define __k_paperlist_waiting @"加载数据..."//等待信息

#define __k_paperlist_detail_title @"试卷详情"
//试卷列表视图控制器成员变量
@interface PaperListViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSString *_subjectCode;
    NSInteger _paperTypeValue;
    UITableView *_tableView;
    PaperService *_service;
    UIFont *_fontTextLabel,*_fontDetailLabel;
}
@end
//试卷列表视图控制器实现
@implementation PaperListViewController
#pragma mark 初始化
-(instancetype)initWithSubjectCode:(NSString *)subjectCode{
    if(self = [super init]){
        _subjectCode = subjectCode;
        _paperTypeValue = 1;
       
        _service = [[PaperService alloc] init];
    }
    return self;
}
#pragma mark 加载组件
- (void)viewDidLoad {
    [super viewDidLoad];
    //分段控制器
    CGFloat y = [self setupSegmentControl];
    //数据列表
    [self setupTableViewWithY:y];
    //NSLog(@"subjectCode => %@",_subjectCode);
    //NSLog(@"y=> %f",y);
}
//安装分段控制器
-(CGFloat)setupSegmentControl{
    CGRect tempFrame = [self loadVisibleViewFrame];
    tempFrame.origin.x = __k_paperlist_segment_margin_left;
    tempFrame.origin.y += __k_paperlist_segment_margin_top;
    tempFrame.size.height = __k_paperlist_segment_height;
    tempFrame.size.width -= (__k_paperlist_segment_margin_left + __k_paperlist_segment_margin_right);
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:__k_paperlist_segment_data];
    segment.frame = tempFrame;
    _paperTypeValue = (segment.selectedSegmentIndex = 0) + 1;
    [segment addTarget:self action:@selector(segmentActionClick:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segment];
    
    return CGRectGetMaxY(tempFrame);
}
//分段器选中事件处理
-(void)segmentActionClick:(UISegmentedControl *)sender{
    //NSLog(@"segmentActionClick：%ld",sender.selectedSegmentIndex);
    if(sender){
        _paperTypeValue = sender.selectedSegmentIndex + 1;
        if(_tableView){
            [_tableView reloadData];
        }
    }
}
//按钮数据列表视图
-(void)setupTableViewWithY:(CGFloat)y{
    CGRect tempFrame = self.view.frame;
    tempFrame.origin.y = y + __k_paperlist_margin_min;
    tempFrame.size.height -= tempFrame.origin.y;
    
    _fontTextLabel = [UIFont systemFontOfSize:__k_paperlist_cell_textLabel_font_size];
    _fontDetailLabel = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    
    _tableView = [[UITableView alloc] initWithFrame:tempFrame style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}
#pragma mark tableView_dataSource
//数据总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    __block NSInteger totals = 0;
    [WaitForAnimation animationWithView:self.view
                              WaitTitle:__k_paperlist_waiting
                                  Block:^{
                                      totals = [_service loadPapersTotalWithSubjectCode:_subjectCode PaperTypeValue:_paperTypeValue];
                                  }];
    return totals;
}
//每条数据展示
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __block UITableViewCell *cell;
    [WaitForAnimation animationWithView:self.view
                              WaitTitle:__k_paperlist_waiting
                                  Block:^{
                                      cell = [tableView dequeueReusableCellWithIdentifier:__k_paperlist_table_cellIdentifier];
                                      if(!cell){
                                          cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                                        reuseIdentifier:__k_paperlist_table_cellIdentifier];
                                          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                          cell.textLabel.font = _fontTextLabel;
                                          cell.textLabel.numberOfLines = 0;
                                          cell.detailTextLabel.font = _fontDetailLabel;
                                          cell.detailTextLabel.textColor = [UIColor darkTextColor];

                                      }
                                      PaperData *paper = [_service loadPaperWithSubjectCode:_subjectCode
                                                                             PaperTypeValue:_paperTypeValue
                                                                                        Row:indexPath.row];
                                      if(paper){
                                          cell.textLabel.text = paper.title;
                                          cell.detailTextLabel.text = [NSString stringWithFormat:@"试题:%ld  发布时间:%@",(long)paper.total,
                                                                       [NSString stringFromDate:paper.createTime withDateFormat:@"yyyy-MM-dd"]];
                                      }
                                  }];
    return cell;
}
#pragma mark tableView_delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PaperData *paper = [_service loadPaperWithSubjectCode:_subjectCode
                                           PaperTypeValue:_paperTypeValue
                                                      Row:indexPath.row];
    //NSLog(@"click:%ld,%ld => %@",(long)indexPath.section, (long)indexPath.row, [paper serializeJSON]);
    if(paper){
        PaperDetailViewController *pdc = [[PaperDetailViewController alloc] initWithPaperCode:paper.code];
        pdc.title = __k_paperlist_detail_title;//paper.title;
        [self.navigationController pushViewController:pdc animated:NO];
    }
}
#pragma mark 内存
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
