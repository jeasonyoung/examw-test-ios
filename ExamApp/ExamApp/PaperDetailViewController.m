//
//  PaperDetailViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/2.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperDetailViewController.h"
#import "UIViewController+VisibleView.h"
#import "NSString+Size.h"
#import "UIColor+Hex.h"

#import "WaitForAnimation.h"

#import "PaperReview.h"
#import "PaperService.h"

#import "ItemViewController.h"

#import "UIViewUtils.h"

#define __k_paperdetailviewcontroller_waiting @"加载数据..."

#define __k_paperdetailviewcontroller_margin_min 5//组件间隔最小间距
#define __k_paperdetailviewcontroller_margin_max 15//
#define __k_paperdetailviewcontroller_top 10//上部间距
#define __k_paperdetailviewcontroller_left 10//左边间距
#define __k_paperdetailviewcontroller_right 10//右边间距
#define __k_paperdetailviewcontroller_font_size 13//标题字体大小
#define __k_paperdetailviewcontroller_border_color 0xdedede//边框颜色
#define __k_paperdetailviewcontroller_bg_color 0xf1f1f1//背景色

#define __k_paperdetailviewcontroller_btn_height 40//按钮高度
#define __k_paperdetailviewcontroller_btn_normal_bg 0xf5f4f9//
#define __k_paperdetailviewcontroller_btn_highlight_bg 0x3277ec//
#define __k_paperdetailviewcontroller_btn_border 0xdedede
#define __k_paperdetailviewcontroller_btn_start @"开始考试"

#define __k_paperdetailviewcontroller_info_structures_title @"大题数:%ld"
#define __k_paperdetailviewcontroller_info_items_title @"总题数:%ld"
#define __k_paperdetailviewcontroller_info_scores_title @"卷面总分:%ld分"
#define __k_paperdetailviewcontroller_info_times_title @"考试时长:%ld分钟"

#define __k_paperdatailviewcontroller_structure_title_font_size 14

//试卷明细视图控制器成员变量
@interface PaperDetailViewController (){
    NSString *_paperCode;
    UIFont *_font;
    PaperReview *_paperReview;
    PaperRecord *_paperRecord;
    PaperService *_service;
}
@end
//试卷明细视图控制器实现
@implementation PaperDetailViewController
#pragma mark 初始化
-(instancetype)initWithPaperCode:(NSString *)paperCode{
    if(self = [super init]){
        _paperCode = paperCode;
        _font = [UIFont systemFontOfSize:__k_paperdetailviewcontroller_font_size];
        _service = [[PaperService alloc] init];
    }
    return self;
}
#pragma mark 加载入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载试卷内容
    [self setupLoadPaperContent];
    //外包滚动容器
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[self loadVisibleViewFrame]];
    //加载试卷标题
    NSNumber *outY = [NSNumber numberWithFloat:0];
    [self setupLoadPaperTitleWithView:scrollView OutY:&outY];
    //加载考试按钮
    [self setupStartButtonWithView:scrollView OutY:&outY];
    //加载试卷信息
    [self setupPaperInfoWithView:scrollView OutY:&outY];
    //加载试卷结构
    [self setupPaperStructruesWithView:scrollView OutY:&outY];
    //计算滚动条出现
    if(CGRectGetHeight(scrollView.frame) < outY.floatValue){
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame), outY.floatValue);
    }
    //添加到界面
    [self.view addSubview:scrollView];
}
#pragma mark 加载试卷内容
-(void)setupLoadPaperContent{
    [WaitForAnimation animationWithView:self.view
                              WaitTitle:__k_paperdetailviewcontroller_waiting
                                  Block:^{
                                      _paperReview = [_service loadPaperWithCode:_paperCode];
                                  }];
}
//加载试卷标题
-(void)setupLoadPaperTitleWithView:(UIView *)view OutY:(NSNumber **)outY{
    if(_paperReview){
        CGRect tempFrame = self.view.frame;
        tempFrame.origin.x = __k_paperdetailviewcontroller_left;
        tempFrame.origin.y = (*outY).floatValue + __k_paperdetailviewcontroller_margin_min;
        tempFrame.size.width -= (__k_paperdetailviewcontroller_left + __k_paperdetailviewcontroller_right);
    
        NSString *title = _paperReview.name;
        if(title && title.length > 0){
            CGSize fontSize = [title sizeWithFont:_font
                                constrainedToSize:tempFrame.size
                                    lineBreakMode:NSLineBreakByWordWrapping];
            tempFrame.size.height = fontSize.height + __k_paperdetailviewcontroller_margin_min;
            UILabel *lbTitle = [[UILabel alloc] initWithFrame:tempFrame];
            lbTitle.numberOfLines = 0;
            lbTitle.font = _font;
            lbTitle.text = title;
            lbTitle.textAlignment = NSTextAlignmentCenter;
            //添加圆角边框
            [UIViewUtils addBoundsRadiusWithView:lbTitle
                                     BorderColor:[UIColor colorWithHex:__k_paperdetailviewcontroller_border_color]
                                 BackgroundColor:[UIColor colorWithHex:__k_paperdetailviewcontroller_bg_color]];
            //添加到界面
            [view addSubview:lbTitle];
            //输出Y坐标
            *outY = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame)];
        }
    }
}
//加载考试考试按钮
-(void)setupStartButtonWithView:(UIView *)view OutY:(NSNumber **)outY{
    if(_paperReview){
        _paperRecord = [_service loadRecordWithPaperCode:_paperReview.code];
        if(!_paperRecord){//没有做题记录
            [self setupSignButtonWithView:view OutY:outY];
            return;
        }
        ///TODO:存在未完成的做题记录
        NSLog(@"==存在未完成的做题记录:");
    }
}
//单个开始按钮
-(void)setupSignButtonWithView:(UIView *)view OutY:(NSNumber **)outY{
    CGRect tempFrame = self.view.frame;
    tempFrame.origin.x = __k_paperdetailviewcontroller_left;
    tempFrame.origin.y = (*outY).floatValue + __k_paperdetailviewcontroller_margin_max;
    tempFrame.size.width -= (__k_paperdetailviewcontroller_left + __k_paperdetailviewcontroller_right);
    tempFrame.size.height =  __k_paperdetailviewcontroller_btn_height;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = tempFrame;
    btn.titleLabel.font = _font;
    UIColor *normal_color = [UIColor colorWithHex:__k_paperdetailviewcontroller_btn_normal_bg],
    *highlight_color = [UIColor colorWithHex:__k_paperdetailviewcontroller_btn_highlight_bg];
    [btn setTitle:__k_paperdetailviewcontroller_btn_start forState:UIControlStateNormal];
    [btn setTitleColor:highlight_color forState:UIControlStateNormal];
    [btn setTitleColor:normal_color forState:UIControlStateHighlighted];
    //注册点击事件
    [btn addTarget:self action:@selector(btnStartClick:) forControlEvents:UIControlEventTouchUpInside];
    //设置边框圆角
    [UIViewUtils addBoundsRadiusWithView:btn
                             BorderColor:[UIColor colorWithHex:__k_paperdetailviewcontroller_btn_border]
                         BackgroundColor:nil];
    //添加到界面
    [view addSubview:btn];
    //输出Y坐标
    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame)];
}
//开始按钮点击事件
-(void)btnStartClick:(UIButton *)sender{
    //NSLog(@"==click %@==> %@",sender,_paperCode);
    ItemViewController *ivc = [[ItemViewController alloc] initWithPaper:_paperReview andRecord:_paperRecord];
    ivc.navigationItem.title = __k_paperdetailviewcontroller_btn_start;
    ivc.hidesBottomBarWhenPushed = NO;
    [self.navigationController pushViewController:ivc animated:NO];
}
//加载试卷信息
-(void)setupPaperInfoWithView:(UIView *)view OutY:(NSNumber **)outY{
    if(_paperReview){
        //定义frame
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.x = __k_paperdetailviewcontroller_left;
        viewFrame.origin.y = (*outY).floatValue + __k_paperdetailviewcontroller_margin_max;
        viewFrame.size.width -= (__k_paperdetailviewcontroller_left + __k_paperdetailviewcontroller_right);
        
        //宽度
        CGFloat maxWidth = 0;
        //大题数
        NSString *structuresText = [NSString stringWithFormat:__k_paperdetailviewcontroller_info_structures_title,(long)_paperReview.structures.count];
        CGSize structureSize = [structuresText sizeWithFont:_font];
        if(maxWidth < structureSize.width){
            maxWidth = structureSize.width;
        }
        
        //试题数
        NSString *itemsText = [NSString stringWithFormat:__k_paperdetailviewcontroller_info_items_title,(long)_paperReview.total];
        CGSize itemSize = [itemsText sizeWithFont:_font];
        if(maxWidth < itemSize.width){
            maxWidth = itemSize.width;
        }
        
        //卷面总分
        NSString *scoresText = [NSString stringWithFormat:__k_paperdetailviewcontroller_info_scores_title,(long)_paperReview.score.integerValue];
        CGSize scoreSize = [scoresText sizeWithFont:_font];
        if(maxWidth < scoreSize.width){
            maxWidth = scoreSize.width;
        }
        
        //考试时长
        NSString *timesText = [NSString stringWithFormat:__k_paperdetailviewcontroller_info_times_title,(long)_paperReview.time];
        CGSize timeSize = [timesText sizeWithFont:_font];
        if(maxWidth < timeSize.width){
            maxWidth = timeSize.width;
        }
        
        //初始化容器面板
        UIView *viewPanel = [[UIView alloc] initWithFrame:viewFrame];
        //**1行1列
        CGFloat col1X = __k_paperdetailviewcontroller_left;
        //大题数
        CGRect tempFrame = CGRectMake(col1X,
                                      __k_paperdetailviewcontroller_margin_min,
                                      structureSize.width,
                                      structureSize.height);
        UILabel *lbStructures = [[UILabel alloc] initWithFrame:tempFrame];
        lbStructures.font = _font;
        lbStructures.text = structuresText;
        [viewPanel addSubview:lbStructures];
        //宽度的一半
        CGFloat halfWith = CGRectGetWidth(viewFrame)/2;
        CGFloat col2X = (maxWidth > halfWith ? maxWidth : halfWith) + __k_paperdetailviewcontroller_margin_min;
        
        //**1行2列
        //试题数
        tempFrame.origin.x = col2X;
        tempFrame.size = itemSize;
        UILabel *lbItem = [[UILabel alloc] initWithFrame:tempFrame];
        lbItem.font = _font;
        lbItem.text = itemsText;
        [viewPanel addSubview:lbItem];
        
        //**2行1列
        //卷面总分
        tempFrame.origin.x = col1X;
        tempFrame.origin.y += tempFrame.size.height + __k_paperdetailviewcontroller_margin_min;
        tempFrame.size = scoreSize;
        UILabel *lbScore = [[UILabel alloc] initWithFrame:tempFrame];
        lbScore.font = _font;
        lbScore.text = scoresText;
        [viewPanel addSubview:lbScore];
        
        //**2行2列
        //考试时长
        tempFrame.origin.x = col2X;
        tempFrame.size = timeSize;
        UILabel *lbTime = [[UILabel alloc] initWithFrame:tempFrame];
        lbTime.font = _font;
        lbTime.text = timesText;
        [viewPanel addSubview:lbTime];
        
        //重载frame
        viewFrame.size.height = tempFrame.origin.y + tempFrame.size.height + __k_paperdetailviewcontroller_margin_min;
        viewPanel.frame = viewFrame;
        //添加圆角
        [UIViewUtils addBoundsRadiusWithView:viewPanel
                                 BorderColor:[UIColor colorWithHex:__k_paperdetailviewcontroller_border_color]
                             BackgroundColor:[UIColor colorWithHex:__k_paperdetailviewcontroller_bg_color]];
        //添加到界面
        [view addSubview:viewPanel];
        //输出Y坐标
        *outY = [NSNumber numberWithFloat:CGRectGetMaxY(viewFrame)];
    }
}
//加载试卷结构信息
-(void)setupPaperStructruesWithView:(UIView *)view OutY:(NSNumber **)outY{
    if(_paperReview && _paperReview.structures && _paperReview.structures.count > 0){
        //定义frame
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.x = __k_paperdetailviewcontroller_left;
        viewFrame.origin.y = (*outY).floatValue + __k_paperdetailviewcontroller_margin_max;
        viewFrame.size.width -= (__k_paperdetailviewcontroller_left + __k_paperdetailviewcontroller_right);
        //初始化容器面板
        UIView *viewPanel = [[UIView alloc] initWithFrame:viewFrame];
        //设置高度
        CGFloat x = __k_paperdetailviewcontroller_margin_min,
                y = 0,
                width = CGRectGetWidth(viewFrame) - (2 * __k_paperdetailviewcontroller_margin_min);
        //设置大题标题字体
        UIFont *fontTitle = [UIFont boldSystemFontOfSize:__k_paperdatailviewcontroller_structure_title_font_size];
        //循环试卷结构
        for(PaperStructure *ps in _paperReview.structures){
            if(ps && ps.title && ps.title.length > 0){
                if(y == 0){
                    y = __k_paperdetailviewcontroller_margin_min;
                }else{
                    y += __k_paperdetailviewcontroller_margin_max;
                }
                NSString *titleContent = [NSString stringWithFormat:@"%@[共%ld题]",ps.title,(long)ps.total];
                //标题显示需要的最小尺寸
                CGSize titleSize = [titleContent sizeWithFont:fontTitle
                                        constrainedToSize:CGSizeMake(width, 1000.0f)
                                            lineBreakMode:NSLineBreakByWordWrapping];
                CGRect tempFrame = CGRectMake(x, y, width, titleSize.height);
                UILabel *lbTitle = [[UILabel alloc] initWithFrame:tempFrame];
                lbTitle.font = fontTitle;
                lbTitle.numberOfLines = 0;
                lbTitle.text = titleContent;
                [viewPanel addSubview:lbTitle];
                y += CGRectGetHeight(tempFrame);
                
                if(ps.desc && ps.desc.length > 0){
                    y += x;
                    NSString *descContent = [NSString stringWithFormat:@"  %@",ps.desc];
                    CGSize descSize = [descContent sizeWithFont:_font
                                          constrainedToSize:CGSizeMake(width, 1000.0f)
                                              lineBreakMode:NSLineBreakByWordWrapping];
                    tempFrame.origin.y = y;
                    tempFrame.size.height = descSize.height;
                    
                    UILabel *lbDesc = [[UILabel alloc] initWithFrame:tempFrame];
                    lbDesc.font = _font;
                    lbDesc.numberOfLines = 0;
                    lbDesc.text = descContent;
                    [viewPanel addSubview:lbDesc];
                    
                    y += CGRectGetHeight(tempFrame);
                }
            }
        }
        //重置高度
        viewFrame.size.height = y + x;
        viewPanel.frame = viewFrame;
        //添加圆角
        [UIViewUtils addBoundsRadiusWithView:viewPanel
                                 BorderColor:[UIColor colorWithHex:__k_paperdetailviewcontroller_border_color]
                             BackgroundColor:[UIColor colorWithHex:__k_paperdetailviewcontroller_bg_color]];
        //添加到界面
        [view addSubview:viewPanel];
        //输出Y坐标
        *outY = [NSNumber numberWithFloat:CGRectGetMaxY(viewFrame) + __k_paperdetailviewcontroller_margin_max];
    }
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end