//
//  ETOptionView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/10.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ETOptionView.h"
#import "NSString+Size.h"
#import "UIColor+Hex.h"

#define __k_etoptionview_top 2//顶部间隔
#define __k_etoptionview_bottom 2//底部间隔
#define __k_etoptionview_left 2//左边间隔
#define __k_etoptionview_right 2//右边间隔
#define __k_etoptionview_margin 5//内部间隔
#define __k_etoptionview_option_margin 10//选项间隔

#define __k_etoptionview_font_size 13//字体尺寸

#define __k_etoptionview_icon_with 22//icon的宽
#define __k_etoptionview_icon_height 22//icon的高

#define __k_etoptionview_observer_filed @"optSelected"
//选项组件成员变量
@interface ETOptionView (){
    UIImageView *_iconView;
    UILabel *_lbTitle;
    UIFont *_font;
}
@end
//选项组件实现
@implementation ETOptionView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame Type:(ETOptionViewType)type OptionCode:(NSString *)code OptionText:(NSString *)text{
    if(self = [super initWithFrame:frame]){
        self.type = type;
        self.optCode = code;
        self.optText = text;
        
        _font = [UIFont systemFontOfSize:__k_etoptionview_font_size];
        [self initilizeOptionView];
        //添加KVO
        [self addObserver:self
               forKeyPath:__k_etoptionview_observer_filed
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
    }
    return self;
}
//初始化
-(void)initilizeOptionView{
    CGFloat maxHeight = 0;
    CGRect tempFrame = CGRectZero;

    UIImage *icon = [self setupIconImageWithType:self.type];
    if(icon){
        tempFrame = CGRectMake(__k_etoptionview_left,
                               __k_etoptionview_top,
                               __k_etoptionview_icon_with,
                               __k_etoptionview_icon_height);
        maxHeight = CGRectGetHeight(tempFrame);
        _iconView = [[UIImageView alloc] initWithImage:icon];
        _iconView.frame = tempFrame;
        [self addSubview:_iconView];
    }
    
    if(self.optText && self.optText.length > 0){
        CGFloat titleWidth = CGRectGetWidth(self.frame) - CGRectGetWidth(tempFrame) - __k_etoptionview_margin - __k_etoptionview_right;
        CGSize titleSize = [self.optText sizeWithFont:_font
                                    constrainedToSize:CGSizeMake(titleWidth, CGFLOAT_MAX)
                                        lineBreakMode:NSLineBreakByWordWrapping];
        if(maxHeight < titleSize.height){
            maxHeight = titleSize.height;
        }
        tempFrame.origin.x += CGRectGetWidth(tempFrame) + __k_etoptionview_margin;
        tempFrame.size.width = titleWidth;
        tempFrame.size.height = maxHeight;
        _lbTitle = [[UILabel alloc] initWithFrame:tempFrame];
        _lbTitle.font = _font;
        _lbTitle.textAlignment = NSTextAlignmentLeft;
        _lbTitle.numberOfLines = 0;
        _lbTitle.textColor = [self setupTextColorWithType:self.type];
        
        //文字上的删除线
        if(self.type == ETOptionViewTypeOfSingleError || self.type == ETOptionViewTypeOfMultyError){
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:self.optText];
            [attri addAttribute:NSStrikethroughStyleAttributeName
                          value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle)
                          range:NSMakeRange(0, self.optText.length)];
            _lbTitle.attributedText = attri;
        }else{
            _lbTitle.text = self.optText;
        }
        //添加到界面
        [self addSubview:_lbTitle];
    }
    //重置高度
    CGRect tmpframe = self.frame;
    tmpframe.size.height = maxHeight + __k_etoptionview_top + __k_etoptionview_bottom;
    self.frame = tmpframe;
    //添加事件
    [self addTarget:self action:@selector(optionViewStatus:) forControlEvents:UIControlEventTouchUpInside];
}
//根据类型获取字体颜色
-(UIColor *)setupTextColorWithType:(ETOptionViewType)type{
    if(type == ETOptionViewTypeOfSingleRight || type == ETOptionViewTypeOfMultyRight){
        return [UIColor greenColor];
    }
    if(type == ETOptionViewTypeOfSingleError || type == ETOptionViewTypeOfMultyError){
        return [UIColor redColor];
    }
    return [UIColor blackColor];
}
//创建图标
-(UIImage *)setupIconImageWithType:(ETOptionViewType)type{
    switch (type) {
        case ETOptionViewTypeOfSingle:
            if(self.optSelected){
                return [UIImage imageNamed:@"option_single_selected.png"];
            }else{
                return [UIImage imageNamed:@"option_single_normal.png"];
            }
        
        case ETOptionViewTypeOfSingleRight:
        case ETOptionViewTypeOfMultyRight:
            return [UIImage imageNamed:@"option_single_right.png"];
            
        case ETOptionViewTypeOfSingleError:
        case ETOptionViewTypeOfMultyError:
            return [UIImage imageNamed:@"option_single_error.png"];
            
        case ETOptionViewTypeOfMulty:
            if(self.optSelected){
                return [UIImage imageNamed:@"option_multy_selected.png"];
            }else{
                return [UIImage imageNamed:@"option_multy_normal.png"];
            }
    }
    return nil;
}
//点击事件处理
-(void)optionViewStatus:(ETOptionView *)sender{
    self.optSelected = YES;//!self.optSelected;
}
//KVO回调
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context{
    if(_iconView && [keyPath isEqualToString:__k_etoptionview_observer_filed]){
        [_iconView setImage:[self setupIconImageWithType:self.type]];
    }
}
#pragma mark 内存回收
-(void)dealloc{
    //移除KVO观察者
    [self removeObserver:self forKeyPath:__k_etoptionview_observer_filed];
}
@end

//选项组合成员变量
@interface ETOptionGroupView (){
    PaperItemType _type;
    NSArray *_options;
    NSMutableDictionary *_optCache;
}
@end
//选项组合实现类
@implementation ETOptionGroupView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame PaperItem:(PaperItem *)item{
    if(self = [super initWithFrame:frame]){
        _optCache = [NSMutableDictionary dictionary];
        if(item){
            _type = item.type;
            _options = item.children;
            [self setupOptionGroup];
        }
    }
    return self;
}
//创建选项集合
-(void)setupOptionGroup{
    if(!_options || _options.count == 0) return;
    CGRect tempFrame = self.frame;
    tempFrame.origin.x = tempFrame.origin.y = 0;
    ETOptionViewType optType = ETOptionViewTypeOfSingle;
        
    for(PaperItem *opt in _options){
        if(!opt)continue;
        if(_optCache && _optCache.count > 0){
            tempFrame.origin.y = CGRectGetMaxY(tempFrame) +  __k_etoptionview_option_margin;
        }
        ETOptionView *optView = [[ETOptionView alloc] initWithFrame:tempFrame
                                                               Type:optType
                                                         OptionCode:opt.code
                                                         OptionText:opt.content];
        //添加事件处理
        [optView addTarget:self action:@selector(itemOptionClick:) forControlEvents:UIControlEventTouchUpInside];
        //添加到缓存
        [_optCache setObject:optView forKey:opt.code];
        //添加到容器
        [self addSubview:optView];
        //
        tempFrame = optView.frame;
    }
    //重置高度
    CGFloat height = CGRectGetMaxY(tempFrame) + __k_etoptionview_option_margin;
    tempFrame = self.frame;
    tempFrame.size.height = height;
    self.frame = tempFrame;
    //self.backgroundColor = [UIColor redColor];
}
//选项点击事件
-(void)itemOptionClick:(ETOptionView *)sender{
    if(_type == PaperItemTypeSingle && _optCache && _optCache.count > 0){//单选
        for(NSString *optCode in _optCache){
            if(!optCode || optCode.length == 0) continue;
            if([optCode isEqualToString:sender.optCode]){
                continue;
            }
            ETOptionView *optView = [_optCache objectForKey:optCode];
            if(optView && optView.optSelected){
                optView.optSelected = NO;
            }
        }
    }
    //触发委托
    if(self.delegate && [self.delegate respondsToSelector:@selector(optionSelected:)]){
        [self.delegate optionSelected:sender];
    }
}
@end


