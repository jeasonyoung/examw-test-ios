//
//  ItemTestView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/7.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemTestView.h"
#import "NSString+Size.h"
#import "UIColor+Hex.h"

//#import "PaperReview.h"
#import "UIViewUtils.h"

#import "ETOptionView.h"

#define __k_itemtestview_top 5//顶部间距
#define __k_itemtestview_left 5//左边间距
#define __k_itemtestview_right 5//右边间距
#define __k_itemtestview_bottom 7//底部间距

#define __k_itemtestview_margin_max 10//最大间距
#define __k_itemtestview_margin_min 5//最小间距

#define __k_itemtestview_font_size 14//试题字体
#define __k_itemtestview_title_borderColor 0xc9f28c//试题标题边框颜色

//考试试题视图成员变量
@interface ItemTestView (){
    PaperItem *_paperItem;
    NSInteger _order,_index;
    UIFont *_font;
    UIColor *_titleBgColor;
}
@end
//考试试题视图构造函数
@implementation ItemTestView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame Item:(PaperItem *)item Order:(NSInteger)order Index:(NSInteger)index{
    if(self = [super initWithFrame:frame]){
        _paperItem = item;
        _order = order;
        _index = index;
        _font = [UIFont systemFontOfSize:__k_itemtestview_font_size];
        _titleBgColor = [UIColor colorWithHex:__k_itemtestview_title_borderColor];
        //创建试题内容
        CGFloat y = [self createContentView];
        if(y > CGRectGetMaxY(self.frame)){
            self.contentSize = CGSizeMake(CGRectGetWidth(self.frame), y);
        }
        //隐藏横向滚动条
        self.showsHorizontalScrollIndicator = NO;
        //隐藏纵向滚动条
        self.showsVerticalScrollIndicator = NO;
        //关闭弹簧效果
        self.bounces = NO;
    }
    return self;
}
//创建试题内容
-(CGFloat)createContentView{
    PaperItemType itemType = (PaperItemType)_paperItem.type;
    CGFloat y = 0;
    switch (itemType) {
        case PaperItemTypeSingle://单选
            y = [self createSingleContent];
            break;
        case PaperItemTypeMulty://多选
        case PaperItemTypeUncertain://不定向选择
            
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
            break;
    }
    return y;
}
//创建单选题
-(CGFloat)createSingleContent{
    NSString *title =  [NSString stringWithFormat:@"%d.%@",_order,_paperItem.content];
    CGRect tempFrame = self.frame;
    NSLog(@"temframe = %@",NSStringFromCGRect(tempFrame));
    tempFrame.origin.x = __k_itemtestview_margin_min;
    tempFrame.origin.y = __k_itemtestview_margin_min;
    tempFrame.size.width -= __k_itemtestview_margin_min*2;
    CGSize titleSize = [title sizeWithFont:_font
                         constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                             lineBreakMode:NSLineBreakByWordWrapping];
    NSLog(@"titleSize:%@ => %@",title, NSStringFromCGSize(titleSize));
    tempFrame.size.height = titleSize.height + __k_itemtestview_margin_min;
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:tempFrame];
    lbTitle.frame = tempFrame;
    lbTitle.font = _font;
    lbTitle.textAlignment = NSTextAlignmentLeft;
    lbTitle.numberOfLines = 0;
    lbTitle.text = title;
     NSLog(@"temframe = %@",NSStringFromCGRect(lbTitle.frame));
    [UIViewUtils addBorderWithView:lbTitle BorderColor:_titleBgColor BackgroundColor:_titleBgColor];
    [self addSubview:lbTitle];
    
    if(_paperItem.children && _paperItem.children.count > 0){
        tempFrame.origin.x = __k_itemtestview_left;
        tempFrame.origin.y = CGRectGetMaxY(tempFrame) + __k_itemtestview_margin_max;
        tempFrame.size.width = CGRectGetWidth(self.frame) - __k_itemtestview_left - __k_itemtestview_right;
        
        ETOptionGroupView *optGroupView = [[ETOptionGroupView alloc] initWithFrame:tempFrame PaperItem:_paperItem];
        if(optGroupView){
            [self addSubview:optGroupView];
            tempFrame = optGroupView.frame;
        }
        //optGroupView.userInteractionEnabled = NO;
    }
    return CGRectGetMaxY(tempFrame);
}

@end