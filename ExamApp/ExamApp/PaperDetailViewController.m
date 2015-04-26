//
//  PaperDetailViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperDetailViewController.h"

#import "PaperDetailViewCell.h"
#import "PaperDetailModel.h"
//#import "UIViewController+VisibleView.h"
//#import "NSString+Size.h"
//#import "UIColor+Hex.h"
//#import "NSDate+TimeZone.h"
//#import "NSString+Date.h"

#import "WaitForAnimation.h"

#import "PaperReview.h"
#import "PaperService.h"
//
//#import "ItemViewController.h"
//#import "ResultViewController.h"
//
#import "PaperRecordService.h"
#import "PaperRecord.h"


//
#define __kPaperDetailViewController_infoStructuresTotal @"大题数:%d"
#define __kPaperDetailViewController_infoItemsTotal @"总题数:%d"
#define __kPaperDetailViewController_infoScores @"卷面总分:%d分"
#define __kPaperDetailViewController_infoTimes @"考试时长:%d分钟"

#define __kPaperDetailViewController_waitMsg @"加载数据..."//

#define __kPaperDetailViewController_cellIdentifierFormat @"cell_%d"
//试卷明细视图控制器成员变量
@interface PaperDetailViewController ()<UITableViewDataSource,UITableViewDelegate,PaperDetailViewCellDeletegate>{
    NSString *_paperCode,*_paperRecordCode;
    UITableView *_tableView;
    NSMutableArray *_dataCache;
}
@end
//试卷明细视图控制器实现
@implementation PaperDetailViewController
#pragma mark 初始化
-(instancetype)initWithPaperCode:(NSString *)paperCode paperRecordCode:(NSString *)paperRecordCode{
    if(self = [super init]){
        _paperCode = paperCode;
        _paperRecordCode = paperRecordCode;
    }
    return self;
}
#pragma mark 初始化
-(instancetype)initWithPaperCode:(NSString *)paperCode{
    return [self initWithPaperCode:paperCode paperRecordCode:nil];
}
#pragma mark 加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭滚动条y轴自动下移
    //self.automaticallyAdjustsScrollViewInsets = NO;
    //数据列表
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    //加载数据
    [self loadDetailsData];
}
//加载数据
-(void)loadDetailsData{
    //初始化等待动画
    WaitForAnimation *wattingFor = [[WaitForAnimation alloc]initWithView:self.view
                                                               WaitTitle:__kPaperDetailViewController_waitMsg];
    //开启等待动画
    [wattingFor show];
    //加载数据缓存
    _dataCache = [NSMutableArray arrayWithCapacity:3];
    PaperService *pService = [[PaperService alloc]init];
    PaperReview *review = [pService loadPaperWithCode:_paperCode];
    //添加标题
    PaperDetailModelFrame *modelTitleFrame = [self setupModelTitleWithPaperReview:review];
    if(modelTitleFrame){
        [_dataCache addObject:modelTitleFrame];
    }
    //添加按钮
    PaperDetailModelFrame *modelBtnsFrame = [self setupModelButtonsWithPaperReview:review];
    if(modelBtnsFrame){
        [_dataCache addObject:modelBtnsFrame];
    }
    //添加描述
    PaperDetailModelFrame *modelDetailFrame = [self setupModelDescWithPaperReview:review];
    if(modelDetailFrame){
        [_dataCache addObject:modelDetailFrame];
    }
    
    //重新刷新数据
    [_tableView reloadData];
    //关闭等待动画
    [wattingFor hide];
}
//试卷标题
-(PaperDetailModelFrame *)setupModelTitleWithPaperReview:(PaperReview *)review{
    NSString *title = (review ? review.name : @"");
    //
    PaperDetailModelFrame *modelFrame = [[PaperDetailModelFrame alloc]init];
    modelFrame.model = [PaperDetailModel modelWithType:__kPaperDetailModel_typeTitle title:title];
    //
    return modelFrame;
}
//添加按钮
-(PaperDetailModelFrame *)setupModelButtonsWithPaperReview:(PaperReview *)review{
    PaperRecord *paperRecord;
    PaperRecordService *paperRecordService = [[PaperRecordService alloc]init];
    if(_paperRecordCode && _paperRecordCode.length > 0){
        paperRecord = [paperRecordService loadRecordWithPaperRecordCode:_paperRecordCode];
    }else{
        paperRecord = [paperRecordService loadLastRecordWithPaperCode:review.code];
    }
    NSString *content = nil;
    if(paperRecord){
        BOOL isView = (paperRecord.status.integerValue == [NSNumber numberWithBool:YES].integerValue);
        content = [NSString stringWithFormat:@"%d",isView];
    }
    PaperDetailModelFrame *modelFrame = [[PaperDetailModelFrame alloc]init];
    modelFrame.model = [PaperDetailModel modelWithType:__kPaperDetailModel_typeButtons title:content];
    return modelFrame;
}
//添加描述信息
-(PaperDetailModelFrame *)setupModelDescWithPaperReview:(PaperReview *)review{
    NSMutableString *content = [NSMutableString string];
    //大题数
    [content appendFormat:__kPaperDetailViewController_infoStructuresTotal,(int)review.structures.count];
    [content appendString:@"<br/>"];
    //试题数
    [content appendFormat:__kPaperDetailViewController_infoItemsTotal,(int)review.total];
    [content appendString:@"<br/>"];
    //卷面总分
    [content appendFormat:__kPaperDetailViewController_infoScores,review.score.intValue];
    [content appendString:@"<br/>"];
    //考试时长
    [content appendFormat:__kPaperDetailViewController_infoTimes,(int)review.time];
    [content appendString:@"<br/><br/><br/>"];
    
    //
    //循环试卷结构
    for(PaperStructure *ps in review.structures){
        if(ps && ps.title && ps.title.length > 0){
            [content appendFormat:@"%@[共%d题]<br/>",ps.title,(int)ps.total];
            if(ps.desc && ps.desc.length > 0){
                [content appendFormat:@" %@",ps.desc];
            }
            [content appendString:@"<br/><br/>"];
        }
    }
    PaperDetailModelFrame *modelFrame = [[PaperDetailModelFrame alloc]init];
    modelFrame.model = [PaperDetailModel modelWithType:__kPaperDetailModel_typeDesc title:content];
    return modelFrame;
}


#pragma mark UITableViewDataSource
//数据的总行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_dataCache){
        return _dataCache.count;
    }
    return 0;
}
//创建数据行
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PaperDetailModelFrame *modelFrame = [_dataCache objectAtIndex:indexPath.row];
    NSString *cellIdentifier = [NSString stringWithFormat:__kPaperDetailViewController_cellIdentifierFormat,(int)modelFrame.modelType];
    PaperDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        switch (modelFrame.modelType) {
            case __kPaperDetailModel_typeTitle:{//标题
                cell = [[PaperDetailTitleViewCell alloc]initWithReuseIdentifier:cellIdentifier];
                break;
            }
            case __kPaperDetailModel_typeButtons:{//按钮
                cell = [[PaperDetailBtnsViewCell alloc]initWithReuseIdentifier:cellIdentifier];
                cell.deletegate = self;
                break;
            }
            case __kPaperDetailModel_typeDesc:{//描述
                cell = [[PaperDetailDescViewCell alloc]initWithReuseIdentifier:cellIdentifier];
                break;
            }
            default:
                break;
        }
        
    }
    [cell loadModelFrame:modelFrame];
    return cell;
}
#pragma mark UITableViewDelegate
//数据行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataCache && _dataCache.count > indexPath.row){
        return [[_dataCache objectAtIndex:indexPath.row] rowHeight];
    }
    return 0;
}
#pragma mark PaperDetailViewCellDeletegate
-(void)detailViewCell:(UITableViewCell *)cell didButtonClick:(UIButton *)sender{
    NSLog(@"sender:%@",sender);
}
////继续开始做题
//-(void)btnContinueStartClik:(UIButton *)sender{
//    //查看结果
//    if(sender && sender.tag == [NSNumber numberWithBool:YES].integerValue){
//        ResultViewController *rvc = [[ResultViewController alloc]initWithPaper:_paperReview andRecord:_paperRecord];
//        rvc.navigationItem.title = __k_paperdetailviewcontroller_btn_view;
//        rvc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:rvc animated:NO];
//        return;
//    }
//    //做题
//    ItemViewController *ivc;
//    if(_recordService && _paperReview && _paperRecord){//加载最新的做题记录
//        PaperItemRecord *itemReord = [_recordService loadLastRecordWithPaperRecordCode:_paperRecord.code];
//        if(itemReord && itemReord.itemCode && itemReord.itemCode.length > 0){
//            NSInteger order = [_paperReview findOrderAtItemCode:itemReord.itemCode];
////            ivc = [[ItemViewController alloc] initWithPaper:_paperReview
////                                                      Order:(order + 1)
////                                                  andRecord:_paperRecord
////                                           andDisplayAnswer:NO];
//        }
//    }
//    //控制器跳转
//    if(!ivc){
////        ivc = [[ItemViewController alloc] initWithPaper:_paperReview
////                                              andRecord:_paperRecord
////                                       andDisplayAnswer:NO];
//    }
//    ivc.navigationItem.title = __k_paperdetailviewcontroller_btn_start;
//    ivc.hidesBottomBarWhenPushed = NO;
//    [self.navigationController pushViewController:ivc animated:NO];
//    //NSLog(@"btnContinueStartClik...");
//}
////重新开始做题
//-(void)btnReNewStartClick:(UIButton *)sender{
//    //重新创建试卷记录
//    if(_recordService){
//        _paperRecord = [_recordService createNewRecordWithPaperCode:_paperReview.code];
//    }
////    //控制器跳转
////    ItemViewController *ivc = [[ItemViewController alloc] initWithPaper:_paperReview
////                                                              andRecord:_paperRecord
////                                                       andDisplayAnswer:NO];
////    ivc.navigationItem.title = __k_paperdetailviewcontroller_btn_start;
////    ivc.hidesBottomBarWhenPushed = NO;
////    [self.navigationController pushViewController:ivc animated:NO];
//}
////两个开始按钮
//-(void)setupDoubleButtonWithView:(UIView *)view OutY:(NSNumber **)outY{
//    CGRect tempFrame = self.view.frame;
//    tempFrame.origin.x = __k_paperdetailviewcontroller_left;
//    tempFrame.origin.y = (*outY).floatValue + __k_paperdetailviewcontroller_margin_max;
//    tempFrame.size.width -= (__k_paperdetailviewcontroller_left + __k_paperdetailviewcontroller_right + __k_paperdetailviewcontroller_margin_max);
//    tempFrame.size.width /= 2;
//    tempFrame.size.height =  __k_paperdetailviewcontroller_btn_height;
//    //继续考试
//    UIButton *btnContinue = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnContinue.frame = tempFrame;
//    btnContinue.titleLabel.font = _font;
//    BOOL isView = (_paperRecord && (_paperRecord.status.integerValue == [NSNumber numberWithBool:YES].integerValue));
//    btnContinue.tag = [NSNumber numberWithBool:isView].integerValue;
//    [btnContinue setTitle:(isView ? __k_paperdetailviewcontroller_btn_view : __k_paperdetailviewcontroller_btn_continue)
//                 forState:UIControlStateNormal];
//    [btnContinue setTitleColor:_colorNormal forState:UIControlStateNormal];
//    [btnContinue setTitleColor:_colorHighlight forState:UIControlStateHighlighted];
//    //注册点击事件
//    [btnContinue addTarget:self action:@selector(btnContinueStartClik:) forControlEvents:UIControlEventTouchUpInside];
//    //设置边框圆角
//    [UIViewUtils addBoundsRadiusWithView:btnContinue BorderColor:_colorBorder BackgroundColor:nil];
//    //添加到界面
//    [view addSubview:btnContinue];
//    
//    //重新考试
//    tempFrame.origin.x = CGRectGetMaxX(tempFrame) + __k_paperdetailviewcontroller_margin_max;
//    UIButton *btnReNew = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnReNew.frame = tempFrame;
//    btnReNew.titleLabel.font = _font;
//    [btnReNew setTitle:__k_paperdetailviewcontroller_btn_renew forState:UIControlStateNormal];
//    [btnReNew setTitleColor:_colorNormal forState:UIControlStateNormal];
//    [btnReNew setTitleColor:_colorHighlight forState:UIControlStateHighlighted];
//    //注册点击事件
//    [btnReNew addTarget:self action:@selector(btnReNewStartClick:) forControlEvents:UIControlEventTouchUpInside];
//    //设置边框圆角
//    [UIViewUtils addBoundsRadiusWithView:btnReNew BorderColor:_colorBorder BackgroundColor:nil];
//    //添加到界面
//    [view addSubview:btnReNew];
//    
//    //输出Y坐标
//    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame)];
//}
////单个开始按钮
//-(void)setupSignButtonWithView:(UIView *)view OutY:(NSNumber **)outY{
//    CGRect tempFrame = self.view.frame;
//    tempFrame.origin.x = __k_paperdetailviewcontroller_left;
//    tempFrame.origin.y = (*outY).floatValue + __k_paperdetailviewcontroller_margin_max;
//    tempFrame.size.width -= (__k_paperdetailviewcontroller_left + __k_paperdetailviewcontroller_right);
//    tempFrame.size.height =  __k_paperdetailviewcontroller_btn_height;
//    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = tempFrame;
//    btn.titleLabel.font = _font;
//    
//    [btn setTitle:__k_paperdetailviewcontroller_btn_start forState:UIControlStateNormal];
//    [btn setTitleColor:_colorNormal forState:UIControlStateNormal];
//    [btn setTitleColor:_colorHighlight forState:UIControlStateHighlighted];
//    //注册点击事件
//    [btn addTarget:self action:@selector(btnReNewStartClick:) forControlEvents:UIControlEventTouchUpInside];
//    //设置边框圆角
//    [UIViewUtils addBoundsRadiusWithView:btn BorderColor:_colorBorder BackgroundColor:nil];
//    //添加到界面
//    [view addSubview:btn];
//    //输出Y坐标
//    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame)];
//}
////加载试卷结构信息
//-(void)setupPaperStructruesWithView:(UIView *)view OutY:(NSNumber **)outY{
//    if(_paperReview && _paperReview.structures && _paperReview.structures.count > 0){
//        //定义frame
//        CGRect viewFrame = self.view.frame;
//        viewFrame.origin.x = __k_paperdetailviewcontroller_left;
//        viewFrame.origin.y = (*outY).floatValue + __k_paperdetailviewcontroller_margin_max;
//        viewFrame.size.width -= (__k_paperdetailviewcontroller_left + __k_paperdetailviewcontroller_right);
//        //初始化容器面板
//        UIView *viewPanel = [[UIView alloc] initWithFrame:viewFrame];
//        //设置高度
//        CGFloat x = __k_paperdetailviewcontroller_margin_min,
//                y = 0,
//                width = CGRectGetWidth(viewFrame) - (2 * __k_paperdetailviewcontroller_margin_min);
//        //设置大题标题字体
//        UIFont *fontTitle = [UIFont boldSystemFontOfSize:__k_paperdatailviewcontroller_structure_title_font_size];
//        //循环试卷结构
//        for(PaperStructure *ps in _paperReview.structures){
//            if(ps && ps.title && ps.title.length > 0){
//                if(y == 0){
//                    y = __k_paperdetailviewcontroller_margin_min;
//                }else{
//                    y += __k_paperdetailviewcontroller_margin_max;
//                }
//                NSString *titleContent = [NSString stringWithFormat:@"%@[共%ld题]",ps.title,(long)ps.total];
//                //标题显示需要的最小尺寸
//                CGSize titleSize = [titleContent sizeWithFont:fontTitle
//                                        constrainedToSize:CGSizeMake(width, 1000.0f)
//                                            lineBreakMode:NSLineBreakByWordWrapping];
//                CGRect tempFrame = CGRectMake(x, y, width, titleSize.height);
//                UILabel *lbTitle = [[UILabel alloc] initWithFrame:tempFrame];
//                lbTitle.font = fontTitle;
//                lbTitle.numberOfLines = 0;
//                lbTitle.text = titleContent;
//                [viewPanel addSubview:lbTitle];
//                y += CGRectGetHeight(tempFrame);
//                
//                if(ps.desc && ps.desc.length > 0){
//                    y += x;
//                    NSString *descContent = [NSString stringWithFormat:@"  %@",ps.desc];
//                    CGSize descSize = [descContent sizeWithFont:_font
//                                          constrainedToSize:CGSizeMake(width, 1000.0f)
//                                              lineBreakMode:NSLineBreakByWordWrapping];
//                    tempFrame.origin.y = y;
//                    tempFrame.size.height = descSize.height;
//                    
//                    UILabel *lbDesc = [[UILabel alloc] initWithFrame:tempFrame];
//                    lbDesc.font = _font;
//                    lbDesc.numberOfLines = 0;
//                    lbDesc.text = descContent;
//                    [viewPanel addSubview:lbDesc];
//                    
//                    y += CGRectGetHeight(tempFrame);
//                }
//            }
//        }
//        //重置高度
//        viewFrame.size.height = y + x;
//        viewPanel.frame = viewFrame;
//        //添加圆角
//        [UIViewUtils addBoundsRadiusWithView:viewPanel
//                                 BorderColor:[UIColor colorWithHex:__k_paperdetailviewcontroller_border_color]
//                             BackgroundColor:[UIColor colorWithHex:__k_paperdetailviewcontroller_bg_color]];
//        //添加到界面
//        [view addSubview:viewPanel];
//        //输出Y坐标
//        *outY = [NSNumber numberWithFloat:CGRectGetMaxY(viewFrame) + __k_paperdetailviewcontroller_margin_max];
//    }
//}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end