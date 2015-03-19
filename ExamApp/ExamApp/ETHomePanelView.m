//
//  ETHomePanelView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ETHomePanelView.h"
#import "UIColor+Hex.h"
#import "HomeData.h"
#import "ETImageButton.h"

#define __k_homepanelview_columns 3//九宫格列数
#define __k_homepanelview_borderColor 0xdedede//边框颜色
#define __k_homepanelview_borderWith 1.0//边框宽度
#define __k_homepanelview_borderRadius 8.0//边框圆角弧度
//主页面板视图(九宫格)成员变量
@interface ETHomePanelView(){
    NSArray *_dataArrays;
}
@end
//主页面板视图(九宫格)实现类
@implementation ETHomePanelView
//创建面板
#pragma mark 创建面板
-(void)createPanel{
    [self createPanelWithFrame:self.frame];
}
#pragma mark 创建面板
-(void)createPanelWithFrame:(CGRect)frame{
    _dataArrays = [HomeData loadHomeData];
    if(_dataArrays.count == 0) return;
    CGSize size = frame.size;
    CGFloat w = size.width / __k_homepanelview_columns, h = size.height / __k_homepanelview_columns;
    
    for(int i = 0; i < _dataArrays.count; i++){
        int col = i % __k_homepanelview_columns;//列
        int row = i / __k_homepanelview_columns;//行
        CGRect tempFrame = CGRectMake(col * w, row * h, w, h);
        
        ETImageButton *btn = [ETImageButton buttonWithType:UIButtonTypeCustom];
        btn.frame = tempFrame;
        [btn createPanelWithData:[_dataArrays objectAtIndex:i]];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }

    self.backgroundColor = [UIColor clearColor];//设置背景色
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = __k_homepanelview_borderRadius;
    self.layer.borderWidth = __k_homepanelview_borderWith;
    self.layer.borderColor = [[UIColor colorWithHex:__k_homepanelview_borderColor] CGColor];
}
#pragma mark 点击事件
-(void)btnClick:(ETImageButton *)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(homePanelViewButtonClick:withTitle:withValue:)]){
        [_delegate homePanelViewButtonClick:self withTitle:sender.title withValue:sender.value];
    }
}
@end
