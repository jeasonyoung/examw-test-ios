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
#import "UIViewUtils.h"

#define __k_homepanelview_columns 3//九宫格列数
#define __k_homepanelview_borderColor 0xdedede//边框颜色
#define __kETHomePanelView_bgColor 0xF5F4F9//背景色
//主页面板视图(九宫格)成员变量
@interface ETHomePanelView(){
    NSArray *_dataArrays;
}
@end
//主页面板视图(九宫格)实现类
@implementation ETHomePanelView
#pragma mark 创建面板
-(void)createPanel{
    _dataArrays = [HomeData loadHomeData];
    NSInteger count = 0;
    if((count = _dataArrays.count) == 0) return;
    
    int rows = (int)(count / __k_homepanelview_columns) + (count % __k_homepanelview_columns == 0 ? 0 : 1);
    CGFloat w = CGRectGetWidth(self.frame) / __k_homepanelview_columns;
    CGFloat h = CGRectGetHeight(self.frame)/rows;
    
    for(NSInteger i = 0; i < count; i++){
        int col = i % __k_homepanelview_columns;//列
        int row = i / __k_homepanelview_columns;//行
        CGRect tempFrame = CGRectMake(col * w, row * h, w, h);
        
        ETImageButton *btn = [ETImageButton buttonWithType:UIButtonTypeCustom];
        btn.frame = tempFrame;
        [btn createPanelWithData:[_dataArrays objectAtIndex:i]];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    //
    [UIViewUtils addBoundsRadiusWithView:self
                             BorderColor:[UIColor colorWithHex:__k_homepanelview_borderColor]
                         BackgroundColor:[UIColor colorWithHex:__kETHomePanelView_bgColor]];
}
#pragma mark 点击事件
-(void)btnClick:(ETImageButton *)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(homePanelViewButtonClick:withTitle:withValue:)]){
        [_delegate homePanelViewButtonClick:self withTitle:sender.title withValue:sender.value];
    }
}
@end
