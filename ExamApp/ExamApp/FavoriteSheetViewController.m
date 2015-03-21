//
//  FavoriteSheetViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FavoriteSheetViewController.h"
#import "UIViewController+VisibleView.h"
#import "UIColor+Hex.h"
#import "NSString+Size.h"

#import "UIViewUtils.h"

#import "FavoriteService.h"

#import "FavoriteViewController.h"

#define __kFavoriteSheetViewController_title @"收藏试题"

#define __kFavoriteSheetViewController_Top 5//顶部间隔
#define __kFavoriteSheetViewController_Left 5//左边间隔
#define __kFavoriteSheetViewController_Right 5//右边间隔
#define __kFavoriteSheetViewController_Bottom 5//底部间隔

#define __kFavoriteSheetViewController_Margin_Max 10//最大间距
#define __kFavoriteSheetViewController_Margin_Min 2//最小间距

#define __kFavoriteSheetViewController_fontSize 14//字体大小

#define __kFavoriteSheetViewController_item_fontSize 12//字体
#define __kFavoriteSheetViewController_item_fontColor 0x545454//
#define __kFavoriteSheetViewController_item_borderColor 0xcccccc//边框颜色
#define __kFavoriteSheetViewController_item_cols 5//每行的列数
#define __kFavoriteSheetViewController_item_height 30//试题号高度
#define __kFavoriteSheetViewController_item_vspace 10//纵向间距
#define __kFavoriteSheetViewController_item_hspace 10//横向间距
//收藏试题答题卡控制器成员变量
@interface FavoriteSheetViewController (){
    NSString *_subjectCode;
    FavoriteService *_service;
}
@end
//收藏试题答题卡控制器实现
@implementation FavoriteSheetViewController
-(instancetype)initWithSubjectCode:(NSString *)subjectCode{
    if(self = [super init]){
        _subjectCode = subjectCode;
    }
    return self;
}
#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //关闭滚动条y轴自动下移
    self.automaticallyAdjustsScrollViewInsets = NO;
    //设置标题
    self.title = __kFavoriteSheetViewController_title;
    //初始化服务类
    _service = [[FavoriteService alloc]init];
    
    //答题卡
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, [self loadTopHeight],
                                                                              CGRectGetWidth(self.view.frame),
                                                                              CGRectGetHeight(self.view.frame))];
    NSNumber *height = [NSNumber numberWithFloat:0];
    //
    [self setupSheetWithPanel:scrollView OutY:&height];
    //重置高度
    if(height.floatValue > CGRectGetHeight(scrollView.frame)){
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame), height.floatValue);
    }
    //添加到界面
    [self.view addSubview:scrollView];
}
//设置答题卡
-(void)setupSheetWithPanel:(UIView *)panel OutY:(NSNumber **)outY{
    if(!_subjectCode || _subjectCode.length == 0)return;
    
    CGFloat w = CGRectGetWidth(panel.frame) - (__kFavoriteSheetViewController_Left + __kFavoriteSheetViewController_Right);
    UIColor *borderColor = [UIColor colorWithHex:__kFavoriteSheetViewController_item_borderColor],
            *fontColor = [UIColor colorWithHex:__kFavoriteSheetViewController_item_fontColor];
    UIFont *font = [UIFont systemFontOfSize:__kFavoriteSheetViewController_fontSize],
            *itemFont = [UIFont systemFontOfSize:__kFavoriteSheetViewController_item_fontSize];
    
    [_service loadSheetWithSubjectCode:_subjectCode SheetsBlock:^(NSString *itemTypeName, NSArray *sheets) {
        CGRect tempFrame = CGRectMake(__kFavoriteSheetViewController_Left, (*outY).floatValue + __kFavoriteSheetViewController_Top, w, 0);
        //试题类型名称
        if(itemTypeName && itemTypeName.length > 0){
            CGSize nameSize = [itemTypeName sizeWithFont:font
                                       constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                                           lineBreakMode:NSLineBreakByWordWrapping];
            tempFrame.size.height = nameSize.height;
            UILabel *lbName = [[UILabel alloc]initWithFrame:tempFrame];
            lbName.font = font;
            lbName.textAlignment = NSTextAlignmentLeft;
            lbName.numberOfLines = 0;
            lbName.text = itemTypeName;
            [panel addSubview:lbName];
        }
        if(sheets && sheets.count > 0){
            tempFrame.origin.y =  CGRectGetMaxY(tempFrame) + __kFavoriteSheetViewController_Margin_Min;
            CGFloat itemWith = (CGRectGetWidth(tempFrame) - (__kFavoriteSheetViewController_item_cols + 1)*__kFavoriteSheetViewController_item_hspace)/__kFavoriteSheetViewController_item_cols;
            CGFloat x = tempFrame.origin.x, y = tempFrame.origin.y;
            
            for(NSInteger i = 0; i < sheets.count; i++){
                NSNumber *order = [sheets objectAtIndex:i];
                if(!order)continue;
                NSInteger col = i % __kFavoriteSheetViewController_item_cols;//列
                NSInteger row = i / __kFavoriteSheetViewController_item_cols;//行
                
                tempFrame.origin.x = x + (itemWith + __kFavoriteSheetViewController_item_hspace)*col + __kFavoriteSheetViewController_item_hspace;
                tempFrame.origin.y = y + (__kFavoriteSheetViewController_item_height + __kFavoriteSheetViewController_item_vspace) * row + __kFavoriteSheetViewController_item_vspace;
                tempFrame.size = CGSizeMake(itemWith, __kFavoriteSheetViewController_item_height);
                
                UIButton *btnItem = [UIButton buttonWithType:UIButtonTypeCustom];
                btnItem.frame = tempFrame;
                btnItem.titleLabel.font = itemFont;
                btnItem.tag = order.integerValue;
                [btnItem setTitleColor:fontColor forState:UIControlStateNormal];
                [btnItem setTitle:[NSString stringWithFormat:@"%ld", (long)(order.integerValue + 1)] forState:UIControlStateNormal];
                [btnItem addTarget:self action:@selector(btnItemOrderClick:) forControlEvents:UIControlEventTouchUpInside];
                [UIViewUtils addBorderWithView:btnItem BorderColor:borderColor BackgroundColor:nil];
                //添加到面板
                [panel addSubview:btnItem];
            }
        }
        //输出高度
        *outY = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame) + __kFavoriteSheetViewController_Bottom];
    }];
}
//试题点击事件
-(void)btnItemOrderClick:(UIButton *)sender{
    NSLog(@"%@,%d",sender,sender.tag);
    NSArray *controllers = self.navigationController.viewControllers;
    if(controllers && controllers.count > 0){
        FavoriteViewController *target;
        for(UIViewController *vc in controllers){
            if(vc && [vc isKindOfClass:[FavoriteViewController class]]){
                target = (FavoriteViewController *)vc;
                break;
            }
        }
        if(target){
            [target loadDataAtOrder:sender.tag];
            [self.navigationController popToViewController:target animated:YES];
        }
    }
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end