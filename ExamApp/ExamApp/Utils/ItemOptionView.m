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

#define __kItemOptionView_Top 2//顶部间隔
#define __kItemOptionView_Bottom 2//底部间隔
#define __kItemOptionView_Left 2//左边间隔
#define __kItemOptionView_Right 2//右边间隔
#define __kItemOptionView_MarginMin 5//内部间隔
#define __kItemOptionView_MarginMax 10//选项间隔

#define __kItemOptionView_fontSize 13//字体尺寸
#define __kItemOptionView_fontColor 0x000000//默认字体颜色
#define __kItemOptionView_rightFontColor 0x00FF00//做对
#define __kItemOptionView_errorFontColor 0xFF0000//做错

#define __kItemOptionView_iconWith 22//icon的宽
#define __kItemOptionView_iconHeight 22//icon的高
#define __kItemOptionView_iconSingleSelected @"option_single_selected.png"//单选选中图片
#define __kItemOptionView_iconSingleNormal @"option_single_normal.png"//单选未选中
#define __kItemOptionView_iconMultySelected @"option_multy_selected.png"//多选选中图片
#define __kItemOptionView_iconMultyNormal @"option_multy_normal.png"//多选未选中图片
#define __kItemOptionView_iconRight @"option_single_right.png"//选项选对
#define __kItemOptionView_iconError @"option_single_error.png"//选项选错

#define __kItemOptionView_observerFiled @"optSelected"

//选项组件成员变量
@interface ItemOptionView (){
    UIImageView *_iconView;
    UILabel *_lbContentView;
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
    }
    return self;
}
//初始化视图
-(void)initilizeOptionView{
    //初始化选项图标UI
    CGRect tempFrame = CGRectMake(__kItemOptionView_Left,__kItemOptionView_Top,
                                  __kItemOptionView_iconWith, __kItemOptionView_iconHeight);
    _iconView = [[UIImageView alloc] initWithFrame:tempFrame];
    [self addSubview:_iconView];
    //初始化试题选项内容
    tempFrame.origin.x = CGRectGetMaxX(tempFrame) + __kItemOptionView_MarginMin;
    tempFrame.size.width = CGRectGetWidth(self.frame) - CGRectGetMinX(tempFrame) - __kItemOptionView_Right;
    _lbContentView = [[UILabel alloc] initWithFrame:tempFrame];
    _lbContentView.font = [UIFont systemFontOfSize:__kItemOptionView_fontSize];
    _lbContentView.textAlignment = NSTextAlignmentLeft;
    _lbContentView.numberOfLines = 0;
    [self addSubview:_lbContentView];
    //重置高度
    tempFrame = self.frame;
    tempFrame.size.height = __kItemOptionView_iconHeight + __kItemOptionView_Bottom;
    self.frame = tempFrame;
    //添加事件
    [self addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
    //添加是否选中的观察者
    [self addObserver:self
           forKeyPath:__kItemOptionView_observerFiled
              options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
              context:nil];
}
//点击事件处理
-(void)optionClick:(ItemOptionView *)sender{
    if(self.type == ItemOptionViewTypeSingle){
        self.optSelected = YES;
    }else if(self.type == ItemOptionViewTypeMulty){
        self.optSelected = !self.optSelected;
    }
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
    //绘制选项内容
    [self drawOptionContent];
}
//绘制选项内容
-(void)drawOptionContent{
    //字体颜色
    UIColor *fontColor = [UIColor colorWithHex:__kItemOptionView_fontColor];
    CGRect tempFrame = CGRectZero;
    //设置图标图片
    if(_iconView){
        tempFrame = _iconView.frame;
        if(_type == ItemOptionViewTypeSingleRight || _type == ItemOptionViewTypeMultyRight){
            fontColor = [UIColor colorWithHex:__kItemOptionView_rightFontColor];
            [_iconView setImage:[UIImage imageNamed:__kItemOptionView_iconRight]];
        }else if(_type == ItemOptionViewTypeSingleError || _type == ItemOptionViewTypeMultyError){
            fontColor = [UIColor colorWithHex:__kItemOptionView_errorFontColor];
            [_iconView setImage:[UIImage imageNamed:__kItemOptionView_iconError]];
        }else{
            self.optSelected = NO;
        }
    }
    //设置选项内容
    if(_lbContentView){
        CGFloat maxHeight = __kItemOptionView_iconHeight;
        //清空文字
         _lbContentView.text = @"";
        tempFrame = _lbContentView.frame;
        if(!_optText || _optText.length == 0){
            _optText = @"";
        }
        CGSize contentSize = [_optText sizeWithFont:_lbContentView.font
                                  constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];
        if(maxHeight < contentSize.height){
            maxHeight = contentSize.height;
        }
        tempFrame.size.height = maxHeight;
        _lbContentView.frame = tempFrame;
        //设置字体颜色
        _lbContentView.textColor = fontColor;
        //做错时
        if(self.type == ItemOptionViewTypeSingleError || self.type == ItemOptionViewTypeMultyError){
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:_optText];
            [attri addAttribute:NSStrikethroughStyleAttributeName
                          value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle)
                          range:NSMakeRange(0, _optText.length)];
            _lbContentView.attributedText = attri;
        }else{
            _lbContentView.text = _optText;
        }
    }
    //重置容器高度
    CGFloat h = CGRectGetMaxY(tempFrame);
    tempFrame = self.frame;
    tempFrame.size.height = h + __kItemOptionView_Bottom;
    self.frame = tempFrame;
}
//KVO回调
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context{
    if(_iconView && [keyPath isEqualToString:__kItemOptionView_observerFiled]){
        [self optionSelectedStatusChange];
    }
}
//选项选中状态改变
-(void)optionSelectedStatusChange{
    if(!_iconView || (_type != ItemOptionViewTypeSingle && _type != ItemOptionViewTypeMulty))return;
    if(_optSelected){//选中
        [_iconView setImage:[UIImage imageNamed:(_type == ItemOptionGroupTypeSingle ?
                                                 __kItemOptionView_iconSingleSelected :
                                                 __kItemOptionView_iconMultySelected)]];
    }else{//未选中
         [_iconView setImage:[UIImage imageNamed:(_type == ItemOptionGroupTypeSingle ?
                                                  __kItemOptionView_iconSingleNormal :
                                                  __kItemOptionView_iconMultyNormal)]];
    }
}
#pragma mark 改变选项类型
-(void)changeOptionType:(ItemOptionViewType)type{
    if(_type != type){
        _type = type;
        [self drawOptionContent];
    }
}
#pragma mark 内存回收
-(void)dealloc{
    //移除KVO观察者
    [self removeObserver:self forKeyPath:__kItemOptionView_observerFiled];
}
#pragma mark 清空
-(void)clean{
    CGRect tempFrame = CGRectZero;
    if(_iconView && _lbContentView){
        _lbContentView.text = @"";
        tempFrame = _lbContentView.frame;
        tempFrame.size.height = CGRectGetHeight(_iconView.frame);
        _lbContentView.frame = tempFrame;
    }
    tempFrame.size.height = 0;
    self.frame = tempFrame;
}
@end


//选项集合数据源
@implementation ItemOptionGroupSource
#pragma mark 加载数据
-(void)loadOptions:(NSArray *)options
         GroupType:(ItemOptionGroupType)type
          Selected:(NSString *)optCode
     DisplayAnswer:(BOOL)displayAnswer
            Answer:(NSString *)answer{
    _options = options;
    _optGropType = type;
    _selectedOptCode = optCode;
    _displayAnswer = displayAnswer;
    _answer = answer;
}
#pragma mark 静态初始化
+(instancetype)sourceOptions:(NSArray *)options
                   GroupType:(ItemOptionGroupType)type
                    Selected:(NSString *)optCode
               DisplayAnswer:(BOOL)displayAnswer
                      Answer:(NSString *)answer{
    ItemOptionGroupSource *dataSource = [[ItemOptionGroupSource alloc] init];
    [dataSource loadOptions:options
                  GroupType:type
                   Selected:optCode
              DisplayAnswer:displayAnswer
                     Answer:answer];
    return dataSource;
}
@end

#define __kItemOptionGroupView_Margin 5//
//选项组合成员变量
@interface ItemOptionGroupView (){
    ItemOptionGroupType _optGroupType;
    NSInteger _optCount;
    NSMutableArray *_optionViewsCache;
    NSString *_answer;
}
@end
//选项组合实现类
@implementation ItemOptionGroupView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _optionViewsCache = [NSMutableArray array];
    }
    return self;
}
#pragma mark 加载数据
-(void)loadData:(ItemOptionGroupSource *)data{
    //清空数据
    _optCount = 0;
    [self clean];
    //获取尺寸
    CGRect tempFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0);
    //加载数据
    if(data){
        _optGroupType = data.optGropType;
        _answer = data.answer;
        //是否只读状态
        self.userInteractionEnabled = !data.IsDisplayAnswer;
        //加载数据
        if(data.options && (_optCount = data.options.count) > 0){
            for(NSInteger i = 0; i < _optCount; i++){
                tempFrame.origin.y = CGRectGetMaxY(tempFrame) + __kItemOptionGroupView_Margin;
                ItemOptionViewType optType = (ItemOptionViewType)((int)data.optGropType);
                PaperItem *option = [data.options objectAtIndex:i];
                if(option){
                    ItemOptionView *optionView = [self createOptionWithFrame:tempFrame Index:i];
                    if(optionView){
                        //加载数据
                        [optionView loadDataWithType:optType OptionCode:option.code OptionText:option.content];
                        if(data.selectedOptCode && data.selectedOptCode.length > 0){
                            BOOL isSelected = [data.selectedOptCode containsString:option.code];
                            if(isSelected){
                                optionView.optSelected = isSelected;
                            }
                        }
                        tempFrame = optionView.frame;
                    }
                }
            }
        }
        //显示答案
        if(data.IsDisplayAnswer){
            [self showDisplayAnswer:data.IsDisplayAnswer];
        }
        //重置容器尺寸
        CGFloat h = CGRectGetMaxY(tempFrame) + __kItemOptionGroupView_Margin;
        tempFrame = self.frame;
        tempFrame.size.height = h;
        self.frame = tempFrame;
    }
}
//创建选项
-(ItemOptionView *)createOptionWithFrame:(CGRect)frame Index:(NSInteger)index{
    ItemOptionView *optView;
    if(_optionViewsCache && _optionViewsCache.count > index){
        optView = [_optionViewsCache objectAtIndex:index];
        optView.frame = frame;
        return optView;
    }
    //初始化选项
    optView = [[ItemOptionView alloc] initWithFrame:frame];
    //添加选项点击处理
    [optView addTarget:self action:@selector(OptionClick:) forControlEvents:UIControlEventTouchUpInside];
    //添加到缓存
    [_optionViewsCache addObject:optView];
    //添加到界面
    [self addSubview:optView];
    //返回选项
    return optView;
}
//选项点击事件
-(void)OptionClick:(ItemOptionView *)sender{
    if(!sender || !_optionViewsCache)return;
    if(_optGroupType == ItemOptionGroupTypeSingle && _optCount <= _optionViewsCache.count){
        for(int i = 0; i < _optCount;i++){
            ItemOptionView *optView = [_optionViewsCache objectAtIndex:i];
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
#pragma mark 是否显示答案
-(void)showDisplayAnswer:(BOOL)displayAnswer{
    if(_optCount > 0 &&_optionViewsCache && _optionViewsCache.count >= _optCount){
        for(NSInteger i = 0; i < _optCount; i++){
            ItemOptionViewType optType = (_optGroupType == ItemOptionGroupTypeSingle ? ItemOptionViewTypeSingle : ItemOptionViewTypeMulty);
            ItemOptionView *optView = [_optionViewsCache objectAtIndex:i];
            if(optView && optView.isOptSelected){//选项被选中
                if(displayAnswer){
                    if(_answer && [_answer containsString:optView.optCode]){//选对
                        optType = (optType == ItemOptionViewTypeSingle ?
                                   ItemOptionViewTypeSingleRight :
                                   ItemOptionViewTypeMultyRight);
                    }else{//选错
                        optType = (optType == ItemOptionViewTypeSingle ?
                                   ItemOptionViewTypeSingleError :
                                   ItemOptionViewTypeMultyError);
                    }
                }
                //重置选项状态
                [optView changeOptionType:optType];
            }
        }
    }
}

#pragma mark 清空
-(void)clean{
    _optCount = 0;
    _answer = @"";
    if(_optionViewsCache && _optionViewsCache.count > 0){
        for(ItemOptionView *opt in _optionViewsCache){
            if(opt){
                [opt clean];
            }
        }
    }
    //重置高度
    CGRect tempFrame = self.frame;
    tempFrame.size.height = 0;
    self.frame = tempFrame;
}
@end