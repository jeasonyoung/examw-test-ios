//
//  ItemTestView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/7.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemContentView.h"
#import "NSString+Size.h"
#import "UIColor+Hex.h"

#import "UIViewUtils.h"

#import "ItemOptionView.h"

#define __k_itemtestview_top 5//顶部间距
#define __k_itemtestview_left 5//左边间距
#define __k_itemtestview_right 5//右边间距
#define __k_itemtestview_bottom 7//底部间距

#define __k_itemtestview_margin_max 10//最大间距
#define __k_itemtestview_margin_min 5//最小间距

#define __k_itemtestview_font_size 14//试题字体
#define __k_itemtestview_title_borderColor 0xc9f28c//试题标题边框颜色

//考试试题视图成员变量
@interface ItemContentView ()<ItemOptionGroupDelegate>{
    UILabel *_lbTitle,*_lbSubTitle;
    ItemOptionGroupView *_optionsView;
}
@end
//考试试题视图构造函数
@implementation ItemContentView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //初始化标题
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.font = [UIFont systemFontOfSize:__k_itemtestview_font_size];
        _lbTitle.textAlignment = NSTextAlignmentLeft;
        _lbTitle.numberOfLines = 0;
        UIColor *bgColor = [UIColor colorWithHex:__k_itemtestview_title_borderColor];
        [UIViewUtils addBorderWithView:_lbTitle BorderColor:bgColor BackgroundColor:bgColor];
        [self addSubview:_lbTitle];
        //初始化二级标题
        
        //隐藏横向滚动条
        self.showsHorizontalScrollIndicator = NO;
        //隐藏纵向滚动条
        self.showsVerticalScrollIndicator = NO;
        //关闭弹簧效果
        self.bounces = NO;
    }
    return self;
}
#pragma mark 加载数据
-(void)loadDataWithItem:(PaperItem *)item Order:(NSInteger)order{
    [self loadDataWithItem:item Order:order Index:0];
}
#pragma mark 加载数据
-(void)loadDataWithItem:(PaperItem *)item Order:(NSInteger)order Index:(NSInteger)index{
    if(item){
        NSNumber *height = [NSNumber numberWithFloat:__k_itemtestview_margin_min];
        //创建标题
        [self createItemTitle:item.content Order:order OutHeight:&height];
        if(item.children && item.children.count > 0){
            //创建内容
            [self createItemContentWithType:(PaperItemType)item.type
                                    Options:item.children OutHeight:&height];
        }
        //答案/解析
        
        //是否出现纵向滚动
        CGFloat y = height.floatValue + __k_itemtestview_bottom;
        if(y > CGRectGetHeight(self.frame)){
            [self setContentSize:CGSizeMake(CGRectGetWidth(self.frame), y)];
        }
    }
}
//创建标题
-(void)createItemTitle:(NSString *)title Order:(NSInteger)order OutHeight:(NSNumber **)oh{
    if(_lbTitle && title && title.length > 0){
        CGRect tempFrame = self.frame;
        tempFrame.origin.x = __k_itemtestview_margin_min;
        tempFrame.origin.y = (*oh).floatValue;
        tempFrame.size.width -= __k_itemtestview_margin_min *2;
        
        NSString *text = [NSString stringWithFormat:@"%d.%@",(int)order,title];
        CGSize textSize = [text sizeWithFont:_lbTitle.font
                           constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
        tempFrame.size.height = textSize.height + __k_itemtestview_margin_min;
        _lbTitle.frame = tempFrame;
        _lbTitle.text = text;
        
        *oh = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame)];
    }
}
//创建内容
-(void)createItemContentWithType:(PaperItemType)itemType Options:(NSArray*)options OutHeight:(NSNumber **)oh {
    if(!options || options.count == 0)return;
    CGRect tempFrame = self.frame;
    tempFrame.origin.x = __k_itemtestview_left;
    tempFrame.origin.y = (*oh).floatValue + __k_itemtestview_top;
    tempFrame.size.width -= (__k_itemtestview_left + __k_itemtestview_right);
    tempFrame.size.height -= tempFrame.origin.y;
    
    //类型
    CGFloat y = 0;
    switch (itemType) {
        case PaperItemTypeSingle://单选
            y = [self setupOptionsWithFrame:tempFrame Options:options Type:ItemOptionViewTypeSingle];
            break;
        case PaperItemTypeMulty://多选
        case PaperItemTypeUncertain://不定向选择
            y = [self setupOptionsWithFrame:tempFrame Options:options Type:ItemOptionViewTypeMulty];
            break;
        case PaperItemTypeJudge://判断题
            break;
        case PaperItemTypeQanda://问答题
            break;
        case PaperItemTypeShareTitle://共享题干题
            break;
        case PaperItemTypeShareAnswer://共享答案题
            break;
        default:
            if(_optionsView){
                [_optionsView clean];
            }
            break;
    }
    //输出高度
    *oh = [NSNumber numberWithFloat:(*oh).floatValue + y];
}
//创建选项
-(CGFloat)setupOptionsWithFrame:(CGRect)frame Options:(NSArray *)options Type:(ItemOptionViewType)type{
    if(options && options.count > 0){
        if(!_optionsView){
            _optionsView = [[ItemOptionGroupView alloc] initWithFrame:frame];
            _optionsView.delegate = self;
            [self addSubview:_optionsView];
        }else{
            _optionsView.frame = frame;
        }
        [_optionsView loadDataWithType:type andOptions:options];
        return CGRectGetHeight(_optionsView.frame);
    }
    return 0;
}
//选中选项
-(void)optionSelected:(ItemOptionView *)sender{
    if(self.itemDelegate && [self.itemDelegate respondsToSelector:@selector(optionWithItemType:selectedCode:)]){
        PaperItemType itemType = PaperItemTypeSingle;
        if(sender.type == ItemOptionViewTypeMulty || sender.type == ItemOptionViewTypeMultyRight || sender.type == ItemOptionViewTypeMultyError){
            itemType = PaperItemTypeMulty;
        }
        [self.itemDelegate optionWithItemType:itemType selectedCode:sender.optCode];
    }
}
@end