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

#define __k_HomePanelView_Columns 3//九宫格列数
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
    CGFloat w = size.width / __k_HomePanelView_Columns, h = size.height / __k_HomePanelView_Columns;
    
    for(int i = 0; i < _dataArrays.count; i++){
        int col = i % __k_HomePanelView_Columns;//列
        int row = i / __k_HomePanelView_Columns;//行
        CGRect tempFrame = CGRectMake(col * w, row * h, w, h);
        
        ETImageButton *btn = [ETImageButton buttonWithType:UIButtonTypeCustom];
        btn.frame = tempFrame;
        [btn createPanelWithData:[_dataArrays objectAtIndex:i]];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }

    self.backgroundColor = [UIColor clearColor];//设置背景色
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8.5;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [[UIColor colorWithHex:0xDEDEDE] CGColor];
}
#pragma mark 点击事件
-(void)btnClick:(ETImageButton *)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(homePanelViewButtonClick:withTitle:withValue:)]){
        [_delegate homePanelViewButtonClick:self withTitle:sender.title withValue:sender.value];
    }
    //NSLog(@"btnClick ===> %@", sender);
}
@end
