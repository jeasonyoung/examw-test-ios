//
//  LearnRecordViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "LearnRecordViewController.h"

#import "LearnRecordService.h"
#import "PaperRecord.h"

#import "NSString+Date.h"
#import "WaitForAnimation.h"

#import "LearnTableViewCell.h"

#import "PaperDetailViewController.h"

#define __kLearnRecordViewController_title @"学习记录"
#define __kLearnRecordViewController_waiting @"加载数据..."
#define __kLearnRecordViewController_cellIdentifier @"cell_identifier_LearnRecord"//

#define __kLearnRecordViewController_cellTitleFontSize 13//字体大小

#define __kLearnRecordViewController_cellImage @"learn_record.png"
#define __kLearnRecordViewController_cellImageWith 50//96
#define __kLearnRecordViewController_cellImageHeight 50//96

//学习记录视图控制器成员变量
@interface LearnRecordViewController ()<UITableViewDataSource,UITableViewDelegate>{
    LearnRecordService *_service;
    NSMutableDictionary *_rowCodeCache,*_rowHeightCache;
    UIFont *_cellTitleFont,*_cellDetailFont;
}
@end
//学习记录视图控制器实现
@implementation LearnRecordViewController
#pragma mark UI加载
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置标题
    self.title = __kLearnRecordViewController_title;
    //初始化服务
    _service = [[LearnRecordService alloc]init];
    //初始化缓存
    _rowCodeCache = [NSMutableDictionary dictionary];
    //初始化高度缓存
    _rowHeightCache = [NSMutableDictionary dictionary];
    //初始化字体
    _cellTitleFont = [UIFont systemFontOfSize:__kLearnRecordViewController_cellTitleFontSize];
    _cellDetailFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    //添加列表
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
}

#pragma mark UITableViewDataSource
//数据总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_service loadAllTotal];
}
//加载数据
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __block LearnTableViewCell *cell;
    [WaitForAnimation animationWithView:self.view WaitTitle:__kLearnRecordViewController_title Block:^{
        cell = [tableView dequeueReusableCellWithIdentifier:__kLearnRecordViewController_cellIdentifier];
        if(!cell){
            cell = [[LearnTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:__kLearnRecordViewController_cellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [_service loadRecordAtRow:indexPath.row Data:^(NSString *paperTypeName, NSString *paperTitle, PaperRecord *record) {
            if(_rowCodeCache && record && record.paperCode && record.paperCode.length > 0){
                [_rowCodeCache setObject:@[record.code,record.paperCode] forKey:[NSNumber numberWithInteger:indexPath.row]];
            }
            cell.paperTypeName = paperTypeName;
            cell.paperTitle = paperTitle;
            cell.useTimes = record.useTimes;
            cell.score = record.score;
            cell.lastTime = record.lastTime;
            CGFloat height = [cell loadData];
            if(_rowHeightCache){
                [_rowHeightCache setObject:[NSNumber numberWithFloat:height]
                                    forKey:[NSNumber numberWithInteger:indexPath.row]];
            }
        }];
        
    }];
    return cell;
}
#pragma mark UITableViewDelegate
//获取Cell高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_rowHeightCache){
        NSNumber *height = [_rowHeightCache objectForKey:[NSNumber numberWithInteger:indexPath.row]];
        if(height){
            return  height.floatValue;
        }
    }
    return 0;
}
//选中事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click:%d", indexPath.row);
    if(_rowCodeCache && _rowCodeCache.count > 0){
        NSArray *arrays = [_rowCodeCache objectForKey:[NSNumber numberWithInteger:indexPath.row]];
        if(!arrays || arrays.count < 2)return;
        NSString *paperRecordCode = [arrays objectAtIndex:0];
        NSString *paperCode = [arrays objectAtIndex:1];
        //NSLog(@"click:%d=>%@",indexPath.row, arrays);
        PaperDetailViewController *pdvc = [[PaperDetailViewController alloc]initWithPaperCode:paperCode
                                                                           andPaperRecordCode:paperRecordCode];
        pdvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pdvc animated:NO];
    }
}
//删除事件处理
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
     NSLog(@"%d=>(section:%d,row:%d)",editingStyle,indexPath.section,indexPath.row);
    //
    if(editingStyle == UITableViewCellEditingStyleDelete && _rowCodeCache && _rowCodeCache.count > 0){//删除数据
        NSArray *arrays = [_rowCodeCache objectForKey:[NSNumber numberWithInteger:indexPath.row]];
        NSString *paperRecordCode = [arrays objectAtIndex:0];
        if(_service){//删除数据库中数据
            [_service deleteWithPaperRecordCode:paperRecordCode];
        }
        //删除缓存
        [_rowCodeCache removeObjectForKey:[NSNumber numberWithInteger:indexPath.row]];
        if(_rowHeightCache && _rowHeightCache.count > 0){
            [_rowHeightCache removeObjectForKey:[NSNumber numberWithInteger:indexPath.row]];
        }
        //删除动画
        [tableView reloadData];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if(_rowHeightCache && _rowHeightCache.count > 0){
        [_rowHeightCache removeAllObjects];
    }
    if(_rowCodeCache && _rowCodeCache.count > 0){
        [_rowCodeCache removeAllObjects];
    }
}
@end
