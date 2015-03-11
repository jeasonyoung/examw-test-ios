//
//  ETOptionView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/10.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemOptionView.h"
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
@interface ItemOptionView (){
    UIImageView *_iconView;
    UILabel *_lbTitle;
}
@end
//选项组件实现
@implementation ItemOptionView
#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //初始化视图
        [self initilizeOptionView];
    }
    return self;
}
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //初始化视图
        [self initilizeOptionView];
        //添加KVO
        [self addObserver:self
               forKeyPath:__k_etoptionview_observer_filed
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
    }
    return self;
}
#pragma mark加载数据
-(void)loadDataWithType:(ItemOptionViewType)type OptionCode:(NSString *)code OptionText:(NSString *)text{
    _type = type;
    _optCode = code;
    _optText = text;
    [self loadData];
}
#pragma mark 加载数据
-(void)loadData{
    CGFloat maxHeight = CGRectGetHeight(_iconView.frame);
    //设置图标图片
    [_iconView setImage:[self setupIconImageWithType:self.type]];
    if(_lbTitle && self.optText && self.optText.length > 0){//设置呈现内容
        CGRect tempFrame = _lbTitle.frame;
        CGSize textSize = [self.optText sizeWithFont:_lbTitle.font
                                   constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
        if(maxHeight < textSize.height){
            tempFrame.size.height = maxHeight = textSize.height;
            //重置选项内容高度
            _lbTitle.frame = tempFrame;
            //重置容器高度
            CGRect tmpframe = self.frame;
            tmpframe.size.height = CGRectGetMaxY(tempFrame) + __k_etoptionview_bottom;
            self.frame = tmpframe;
        }
        //设置字体颜色
        _lbTitle.textColor = [self setupTextColorWithType:self.type];
        //文字上的删除线
        if(self.type == ItemOptionViewTypeSingleError || self.type == ItemOptionViewTypeMultyError){
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:self.optText];
            [attri addAttribute:NSStrikethroughStyleAttributeName
                          value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle)
                          range:NSMakeRange(0, self.optText.length)];
            _lbTitle.attributedText = attri;
        }else{
            _lbTitle.text = self.optText;
        }
    }
}
//初始化
-(void)initilizeOptionView{
    //初始化图标UI
    CGRect tempFrame = CGRectMake(__k_etoptionview_left,
                                  __k_etoptionview_top,
                                  __k_etoptionview_icon_with,
                                  __k_etoptionview_icon_height);
    _iconView = [[UIImageView alloc] initWithFrame:tempFrame];
    [self addSubview:_iconView];
    //初始化试题内容
    tempFrame.origin.x = CGRectGetMaxX(tempFrame) + __k_etoptionview_margin;
    tempFrame.size.width = CGRectGetWidth(self.frame) - CGRectGetMinX(tempFrame) - __k_etoptionview_right;;
    _lbTitle = [[UILabel alloc] initWithFrame:tempFrame];
    _lbTitle.font = [UIFont systemFontOfSize:__k_etoptionview_font_size];
    _lbTitle.textAlignment = NSTextAlignmentLeft;
    _lbTitle.numberOfLines = 0;
    [self addSubview:_lbTitle];
    //重置高度
    CGRect tmpframe = self.frame;
    tmpframe.size.height = CGRectGetMaxY(tempFrame) + __k_etoptionview_bottom;
    self.frame = tmpframe;
    //添加事件
    [self addTarget:self action:@selector(optionViewStatus:) forControlEvents:UIControlEventTouchUpInside];
}
//根据类型获取字体颜色
-(UIColor *)setupTextColorWithType:(ItemOptionViewType)type{
    if(type == ItemOptionViewTypeSingleRight || type == ItemOptionViewTypeMultyRight){
        return [UIColor greenColor];
    }
    if(type == ItemOptionViewTypeSingleError || type == ItemOptionViewTypeMultyError){
        return [UIColor redColor];
    }
    return [UIColor blackColor];
}
//创建图标
-(UIImage *)setupIconImageWithType:(ItemOptionViewType)type{
    switch (type) {
        case ItemOptionViewTypeSingle:
            if(self.optSelected){
                return [UIImage imageNamed:@"option_single_selected.png"];
            }else{
                return [UIImage imageNamed:@"option_single_normal.png"];
            }
        
        case ItemOptionViewTypeSingleRight:
        case ItemOptionViewTypeMultyRight:
            return [UIImage imageNamed:@"option_single_right.png"];
            
        case ItemOptionViewTypeSingleError:
        case ItemOptionViewTypeMultyError:
            return [UIImage imageNamed:@"option_single_error.png"];
            
        case ItemOptionViewTypeMulty:
            if(self.optSelected){
                return [UIImage imageNamed:@"option_multy_selected.png"];
            }else{
                return [UIImage imageNamed:@"option_multy_normal.png"];
            }
    }
    return nil;
}
//点击事件处理
-(void)optionViewStatus:(ItemOptionView *)sender{
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
@interface ItemOptionGroupView (){
    ItemOptionViewType _type;
    NSInteger _optCount;
    NSMutableArray *_optionsCache;
}
@end
//选项组合实现类
@implementation ItemOptionGroupView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _optionsCache = [NSMutableArray array];
    }
    return self;
}
#pragma mark 加载数据
-(void)loadDataWithType:(ItemOptionViewType)type andOptions:(NSArray *)options{
    _type = type;
    //清空子控件
    [self cleanWithAllCache:NO];
    //是否只读状态
    self.userInteractionEnabled = (_type == ItemOptionViewTypeSingle || _type == ItemOptionViewTypeMulty);
    //加载数据
    if(options && (_optCount = options.count) > 0){
        CGRect tempFrame = self.frame;
        tempFrame.origin.x = tempFrame.origin.y = 0;
        for(int i = 0; i < options.count;i++){
            if(i > 0){
                tempFrame.origin.y = CGRectGetMaxY(tempFrame) +  __k_etoptionview_option_margin;
            }
            PaperItem *option = [options objectAtIndex:i];
            ItemOptionView *optionView = [self createOptionWithFrame:tempFrame Index:i];
            if(option && optionView){
                //加载数据
                [optionView loadDataWithType:_type OptionCode:option.code OptionText:option.content];
                //添加到容器
                [self addSubview:optionView];
                tempFrame = optionView.frame;
            }
        }
        //重置容器高度
        CGFloat height = CGRectGetMaxY(tempFrame) + __k_etoptionview_option_margin;
        tempFrame = self.frame;
        tempFrame.size.height = height;
        self.frame = tempFrame;
    }
}
#pragma mark 清空
-(void)clean{
    [self cleanWithAllCache:YES];
}
//清空
-(void)cleanWithAllCache:(BOOL)all{
    if(all && _optionsCache && _optionsCache.count > 0){
        [_optionsCache removeAllObjects];
    }
    //清空子控件
    NSArray *subViews = self.subviews;
    if(subViews && subViews.count > 0){
        for(UIView *sub in subViews){
            if(!sub) continue;
            [sub removeFromSuperview];
        }
    }
}
//创建选项
-(ItemOptionView *)createOptionWithFrame:(CGRect)frame Index:(int)index{
    ItemOptionView *optView;
    if(_optionsCache.count > index){
        optView = [_optionsCache objectAtIndex:index];
        optView.frame = frame;
        return optView;
    }
    optView = [[ItemOptionView alloc] initWithFrame:frame];
    [optView addTarget:self action:@selector(itemOptionClick:) forControlEvents:UIControlEventTouchUpInside];
    [_optionsCache addObject:optView];
    return optView;
}
//选项点击事件
-(void)itemOptionClick:(ItemOptionView *)sender{
    if(!sender)return;
    if(_type == ItemOptionViewTypeSingle && _optCount <= _optionsCache.count){
        for(int i = 0; i < _optCount;i++){
            ItemOptionView *optView = [_optionsCache objectAtIndex:i];
            if(!optView || [sender.optCode isEqualToString:optView.optCode]){
                continue;
            }
            if(optView.optSelected){
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