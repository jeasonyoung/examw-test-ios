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
    NSMutableDictionary *_rowCodeCache;
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
    __block UITableViewCell *cell;
    [WaitForAnimation animationWithView:self.view WaitTitle:__kLearnRecordViewController_title Block:^{
        cell = [tableView dequeueReusableCellWithIdentifier:__kLearnRecordViewController_cellIdentifier];
        if(!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:__kLearnRecordViewController_cellIdentifier];
//            //设置图片
//            cell.imageView.image = [UIImage imageNamed:__kLearnRecordViewController_cellImage];
//            //调整大小
//            CGSize imageSize = CGSizeMake(__kLearnRecordViewController_cellImageWith, __kLearnRecordViewController_cellImageHeight);
//            UIGraphicsBeginImageContextWithOptions(imageSize, NO, UIScreen.mainScreen.scale);
//            CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
//            [cell.imageView.image drawInRect:imageRect];
//            cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
            
            UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:__kLearnRecordViewController_cellImage]];
            imgView.frame =  CGRectMake(0, 0, __kLearnRecordViewController_cellImageWith, __kLearnRecordViewController_cellImageHeight);
            [cell.contentView addSubview:imgView];
            cell.indentationLevel = 1;
            cell.indentationWidth = __kLearnRecordViewController_cellImageWith;
            
            //
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.textLabel.font = _cellTitleFont;
            cell.textLabel.numberOfLines = 0;
            
            cell.detailTextLabel.font = _cellDetailFont;
            cell.detailTextLabel.textColor = [UIColor darkTextColor];
            cell.detailTextLabel.numberOfLines = 0;
        }
        cell.textLabel.text = cell.detailTextLabel.text = @"";
        [_service loadRecordAtRow:indexPath.row Data:^(NSString *paperTypeName, NSString *paperTitle, PaperRecord *record) {
            if(_rowCodeCache && record && record.paperCode && record.paperCode.length > 0){
                [_rowCodeCache setObject:@[record.code,record.paperCode] forKey:[NSNumber numberWithInteger:indexPath.row]];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"[%@]%@",paperTypeName,paperTitle];
            float minute = record.useTimes.floatValue / 60;
            NSMutableString *detail = [NSMutableString string];
            [detail appendFormat:@"耗时:%d分%d秒", (int)minute,(int)((minute - (int)minute) *60)];
            if([record.status isEqualToNumber:[NSNumber numberWithBool:YES]] && record.score && record.score.floatValue > 0){
                [detail appendFormat:@" 得分:%.1f",record.score.floatValue];
            }
            [detail appendFormat:@"  %@",[NSString stringFromDate:record.lastTime]];
            cell.detailTextLabel.text = detail;
        }];
        
    }];
    return cell;
}

#pragma mark UITableViewDelegate
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
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
