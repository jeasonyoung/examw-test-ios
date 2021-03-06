//
//  ETImageButton.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ETImageButton.h"
#import "UIColor+Hex.h"
#import "NSString+Size.h"
#import "HomeData.h"

#import "UIViewUtils.h"

#define __kETImageButton_margin 5
#define __kETImageButton_normalFontColor 0x3277EC//设置常态字体颜色
#define __kETImageButton_highlightFontColor 0xF5F4F9//高亮字体颜色
#define __kETImageButton_borderColor 0xDEDEDE//边框颜色

#define __kETImageButton_borderWith 0.28//边框宽度

//图片按钮成员变量
@interface ETImageButton(){
    UIFont *_font;
    UIColor *_normalFontColor,*_highlightFontColor,*_normalBackgroundColor,*_highlightBackgroundColor,*_borderColor;
    CGSize _titleSize;
    CGPoint _titleCenter;
    UIImageView *_imageView;
}
@end
//图片按钮实现类
@implementation ETImageButton
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //设置默认字体
        _font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        //设置常态字体颜色
        _normalFontColor = [UIColor colorWithHex:__kETImageButton_normalFontColor];
        //设置高亮字体颜色
        _highlightFontColor = [UIColor colorWithHex:__kETImageButton_highlightFontColor];
        //设置常态背景颜色
        _normalBackgroundColor = _highlightFontColor;
        //设置高亮背景色
        _highlightBackgroundColor = _normalFontColor;
        //边框颜色
        _borderColor = [UIColor colorWithHex:__kETImageButton_borderColor];
    }
    return self;
}
#pragma mark 创建面板
-(void)createPanelWithData:(HomeData *)data{
    if(data == nil)return;
    _title = data.title;
    _value = data.value;
    //[self setBackgroundColor:_normalBackgroundColor];
    [self setTitle:data.title forState:UIControlStateNormal];
    [self.titleLabel setFont:_font];
    [self setTitleColor:_normalFontColor forState:UIControlStateNormal];
    [self setTitleColor:_highlightFontColor forState:UIControlStateHighlighted];
    
   
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:data.normalImage]
                                   highlightedImage:[UIImage imageNamed:data.selectedImage]];
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
    CGFloat imageWH = (width > height ? height : width) * 0.6;
    
    CGSize imageSize = CGSizeMake(imageWH, imageWH);
    _imageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGFloat marginHeight = (height - imageSize.height) / 2;
    if(data.title != nil){
        CGSize titleSize = [data.title sizeWithFont:_font];
        if(titleSize.width > width){
            titleSize.width = width;
        }
        _titleSize = titleSize;
        marginHeight =  (height - imageSize.height - titleSize.height) / 3;
        _titleCenter = CGPointMake(width / 2, marginHeight + imageSize.height + __kETImageButton_margin + (_titleSize.height / 2));
        
    }
    _imageView.center = CGPointMake(width / 2, marginHeight + (imageSize.height / 2));
    [self addSubview:_imageView];
    
    
    [UIViewUtils addBorderWithView:self
                       BorderColor:_borderColor
                       BorderWidth:__kETImageButton_borderWith
                   BackgroundColor:_normalBackgroundColor];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(0, 0, _titleSize.width, _titleSize.height);
    self.titleLabel.center = _titleCenter;
    
    self.backgroundColor = self.isHighlighted ? _highlightBackgroundColor : _normalBackgroundColor;
    _imageView.highlighted = self.isHighlighted;
    
}
@end
