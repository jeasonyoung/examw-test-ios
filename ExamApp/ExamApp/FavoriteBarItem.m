//
//  FavoriteButton.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FavoriteBarItem.h"

#import "UIColor+Hex.h"

#import "UIViewUtils.h"

#define __kFavoriteBarItem_with 30//收藏宽度
#define __kFavoriteBarItem_height 30//收藏高度
#define __kFavoriteBarItem_bgColor 0xCCCCCC//收藏的背景色
#define __kFavoriteBarItem_imgNormal @"favorite_normal.png"//未被收藏
#define __kFavoriteBarItem_imghighlight @"favorite_highlight.png"//已被收藏

//收藏按钮成员变量
@interface FavoriteBarItem(){
    UIButton *_btnFavorite;
    UIImage *_imgNormal,*_imgHighlight;
}
@end
//收藏按钮实现
@implementation FavoriteBarItem
#pragma mark 初始化
-(instancetype)initWidthDelegate:(id<FavoriteBarItemDelegate>)delegate{
    _btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnFavorite.frame = CGRectMake(0, 0, __kFavoriteBarItem_with, __kFavoriteBarItem_height);
    if(self = [super initWithCustomView:_btnFavorite]){
        _delegate = delegate;
        
        [self setupInitComponents];
    }
    return self;
}
#pragma mark 初始化
-(void)setupInitComponents{
    _imgNormal = [UIImage imageNamed:__kFavoriteBarItem_imgNormal];
    _imgHighlight = [UIImage imageNamed:__kFavoriteBarItem_imghighlight];
    
    UIColor *bgColor = [UIColor colorWithHex:__kFavoriteBarItem_bgColor];
    [UIViewUtils addBoundsRadiusWithView:_btnFavorite BorderColor:bgColor BackgroundColor:bgColor];
    [_btnFavorite addTarget:self action:@selector(btnFavoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setState:NO];
}
//按钮事件
-(void)btnFavoriteClick:(UIButton *)sender{
    //设置状态
    [self setState:!_state];
    //触发事件委托
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickWithFavorite:)]){
        [self.delegate clickWithFavorite:self];
    }
}
#pragma mark 设置状态
-(void)setState:(BOOL)state{
    _state = state;
    if(_btnFavorite){
        UIImage *bgImage = (_state ? _imgHighlight : _imgNormal);
        [_btnFavorite setBackgroundImage:bgImage forState:UIControlStateNormal];
    }
}
#pragma mark 加载数据
-(void)reloadData{
    if(self.delegate && [self.delegate respondsToSelector:@selector(stateWithFavorite:)]){
        [self setState:[self.delegate stateWithFavorite:self]];
    }
}
@end
