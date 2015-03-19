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
#import "ItemAnswerView.h"

//试题显示数据源
@implementation ItemContentSource
#pragma mark 加载数据
-(void)loadDataWithStructureCode:(NSString *)code
                          Source:(PaperItem *)source
                           Index:(NSInteger)index
                           Order:(NSInteger)order
                   SelectedValue:(NSString *)value{
    _structureCode = code;
    _source = source;
    _index = index;
    _order = order;
    _value = value;
}
#pragma mark 静态初始化
+(instancetype)itemContentStructureCode:(NSString *)code
                                 Source:(PaperItem *)source
                                  Index:(NSInteger)index
                                  Order:(NSInteger)order
                          SelectedValue:(NSString *)value {
    ItemContentSource *data = [[ItemContentSource alloc] init];
    [data loadDataWithStructureCode:code Source:source Index:index Order:order SelectedValue:value];
    return data;
}
@end


#define __k_itemcontentview_top 5//顶部间距
#define __k_itemcontentview_left 5//左边间距
#define __k_itemcontentview_right 5//右边间距
#define __k_itemcontentview_bottom 7//底部间距

#define __k_itemcontentview_margin_max 10//最大间距
#define __k_itemcontentview_margin_min 5//最小间距

#define __k_itemcontentview_font_size 14//试题字体
#define __k_itemcontentview_title_borderColor 0xc9f28c//试题标题边框颜色

#define __kPaperItemJudgeAnswerRightTitle @"正确"//判断题答案名称
#define __kPaperItemJudgeAnswerWrongTitle @"错误"//判断题答案名称

//考试试题视图成员变量
@interface ItemContentView ()<ItemOptionGroupDelegate>{
    BOOL _displayAnswer;
    ItemContentSource *_itemSource;
    UIFont *_font;
    UILabel *_lbTitle,*_lbSubTitle;
    ItemOptionGroupView *_optionsView;
    ItemAnswerView *_answerView;
}
@end
//考试试题视图构造函数
@implementation ItemContentView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //默认不显示答案
        _displayAnswer = NO;
        //初始化字体
        _font = [UIFont systemFontOfSize:__k_itemcontentview_font_size];
        //初始化标题
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.font = _font;
        _lbTitle.textAlignment = NSTextAlignmentLeft;
        _lbTitle.numberOfLines = 0;
        UIColor *bgColor = [UIColor colorWithHex:__k_itemcontentview_title_borderColor];
        [UIViewUtils addBorderWithView:_lbTitle BorderColor:bgColor BackgroundColor:bgColor];
        [self addSubview:_lbTitle];
        //初始化二级标题
        _lbSubTitle = [[UILabel alloc] init];
        _lbSubTitle.font = _font;
        _lbSubTitle.textAlignment = NSTextAlignmentLeft;
        _lbSubTitle.numberOfLines = 0;
        [self addSubview:_lbSubTitle];
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
-(void)loadDataWithSource:(ItemContentSource *)source{
    [self loadDataWithSource:source andDisplayAnswer:NO];
}
#pragma mark 加载数据并显示答案
-(void)loadDataWithSource:(ItemContentSource *)source andDisplayAnswer:(BOOL)displayAnswer{
    //清空数据
    [self clean];
    //数据赋值
    _itemSource =  source;
    //是否显示答案
    _displayAnswer = displayAnswer;
    //间距高度
    NSNumber *ty = [NSNumber numberWithFloat:__k_itemcontentview_margin_min];
    //加载数据
    PaperItem *item;
    if(_itemSource && (item = _itemSource.source)){
        //题型
        PaperItemType itemType = (PaperItemType)item.type;
        //创建标题
        [self setupItemTitle:item.content Order:(_itemSource.order + 1) ItemType:itemType OutY:&ty];
        //创建题目内容
        [self setupItemContentWithType:itemType Item:item OutY:&ty];
    }
    //是否出现纵向滚动
    CGFloat y = ty.floatValue + __k_itemcontentview_bottom;
    if(y > CGRectGetHeight(self.frame)){
        [self setContentSize:CGSizeMake(CGRectGetWidth(self.frame), y)];
    }
}
//创建题目内容
-(void)setupItemContentWithType:(PaperItemType)itemType Item:(PaperItem *)item OutY:(NSNumber **)outY{
    CGRect tempFrame = CGRectMake(__k_itemcontentview_left,
                                  (*outY).floatValue + __k_itemcontentview_top,
                                  CGRectGetWidth(self.frame) - (__k_itemcontentview_left + __k_itemcontentview_right),
                                  0);
    
    //NSLog(@"setupItemContentWithType-frame:%@, outY:%f",NSStringFromCGRect(tempFrame), (*outY).floatValue);
    switch (itemType) {
        case PaperItemTypeSingle:{//单选
            //单选
            [self setupOptionsWithFrame:tempFrame Type:ItemOptionGroupTypeSingle Options:item.children RightAnswer:item.answer OutY:outY];
            //答案及其解析
            [self setupAnswerWithOptions:item.children RightAnswer:item.answer Analysis:item.analysis OutY:outY];
        }
        break;
        case PaperItemTypeMulty://多选
        case PaperItemTypeUncertain://不定向
        {
            //多选
            [self setupOptionsWithFrame:tempFrame Type:ItemOptionGroupTypeMulty Options:item.children RightAnswer:item.answer OutY:outY];
            //答案及其解析
            [self setupAnswerWithOptions:item.children RightAnswer:item.answer Analysis:item.analysis OutY:outY];
        }
        break;
        case PaperItemTypeJudge:{//判断题
            //判断题
            [self setupJudgeWithFrame:tempFrame Item:item OutY:outY];
        }
        break;
        case PaperItemTypeQanda:{//问答题
            ///TODO:问答题
        }
        break;
        case PaperItemTypeShareTitle:{//共享题干题
            if(item.children && item.children.count > 0){
                PaperItem *childItem = [item.children objectAtIndex:_itemSource.index];
                if(childItem){//子题
                    //二级标题
                    [self setupItemSubTitle:childItem.content Order:(_itemSource.order + 1) ItemType:itemType OutY:outY];
                    PaperItemType childItemType = (PaperItemType)childItem.type;
                    if(childItemType != PaperItemTypeShareTitle && childItemType != PaperItemTypeShareAnswer){
                        //创建选项
                        [self setupItemContentWithType:childItemType Item:childItem OutY:outY];
                    }
                }
            }
        }
        break;
        case PaperItemTypeShareAnswer:{//共享答案题
            NSInteger count = 0;
            if(item.children && (count = item.children.count) > 0){
                PaperItem *p = [item.children objectAtIndex:(count - 1)];
                if(p && p.children && p.children.count > 0){
                    PaperItem *childItem = [p.children objectAtIndex:_itemSource.index];
                    if(childItem){//子题
                        NSMutableArray *optionArrays = [NSMutableArray array];
                        for(NSInteger i = 0; i < count - 1; i++){
                            PaperItem *opt = [item.children objectAtIndex:i];
                            if(opt){
                                [optionArrays addObject:opt];
                            }
                        }
                        //二级标题
                        [self setupItemSubTitle:childItem.content Order:(_itemSource.order + 1) ItemType:itemType OutY:outY];
                        PaperItemType childItemType = (PaperItemType)childItem.type;
                        if(childItemType != PaperItemTypeShareTitle && childItemType != PaperItemTypeShareAnswer){
                            if(childItemType == PaperItemTypeSingle){//单选
                                
                                [self setupOptionsWithFrame:tempFrame Type:ItemOptionGroupTypeSingle Options:[optionArrays copy] RightAnswer:childItem.answer OutY:outY];
                                //答案及其解析
                                [self setupAnswerWithOptions:[optionArrays copy] RightAnswer:childItem.answer Analysis:childItem.analysis OutY:outY];
                                
                            }else if(childItemType == PaperItemTypeMulty || childItemType == PaperItemTypeUncertain){//多选
                                
                                [self setupOptionsWithFrame:tempFrame Type:ItemOptionGroupTypeMulty Options:[optionArrays copy] RightAnswer:childItem.answer OutY:outY];
                                //答案及其解析
                                [self setupAnswerWithOptions:[optionArrays copy] RightAnswer:childItem.answer Analysis:childItem.analysis OutY:outY];
                            
                            }else if(childItemType == PaperItemTypeJudge){//判断
                                [self setupJudgeWithFrame:tempFrame Item:childItem OutY:outY];
                            
                            }
                        }
                    }
                }
            }
        }
        break;
    }
}
//创建标题
-(void)setupItemTitle:(NSString *)title Order:(NSInteger)order ItemType:(PaperItemType)itemType OutY:(NSNumber **)outY{
    if(_lbTitle){
        CGRect tempFrame = CGRectMake(__k_itemcontentview_margin_min,
                                      (*outY).floatValue,
                                      CGRectGetWidth(self.frame) - __k_itemcontentview_margin_min*2,
                                      0);
        NSString *text = @"";
        if(title && title.length > 0){
            text = [NSString stringWithFormat:@"%d.%@",(int)order,title];
            if(itemType == PaperItemTypeShareTitle || itemType == PaperItemTypeShareAnswer){
                text = title;
            }
            CGSize textSize = [text sizeWithFont:_lbTitle.font
                               constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
            tempFrame.size.height = textSize.height + __k_itemcontentview_margin_min;
        }
        _lbTitle.frame = tempFrame;
        _lbTitle.text = text;
        
        *outY = [NSNumber numberWithFloat:CGRectGetMaxY(_lbTitle.frame)];
        
        //NSLog(@"setupItemTitle-frame:%@, outY:%f",NSStringFromCGRect(_lbTitle.frame), (*outY).floatValue);
    }
}
//创建子标题
-(void)setupItemSubTitle:(NSString *)title Order:(NSInteger)order ItemType:(PaperItemType)itemType OutY:(NSNumber **)outY{
    if(_lbSubTitle){
        CGRect tempFrame = CGRectMake(__k_itemcontentview_margin_min,
                                      (*outY).floatValue + __k_itemcontentview_margin_max,
                                      CGRectGetWidth(self.frame) - __k_itemcontentview_margin_min*2,
                                      0);
        NSString *text = @"";
        if(title && title.length){
            text = title;
            if(itemType == PaperItemTypeShareTitle){
                text = [NSString stringWithFormat:@"%d.%@",(int)order,title];
            }
            CGSize textSize = [text sizeWithFont:_lbTitle.font
                               constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                                   lineBreakMode:NSLineBreakByWordWrapping];
            tempFrame.size.height = textSize.height + __k_itemcontentview_margin_min;
        }
        _lbSubTitle.frame = tempFrame;
        _lbSubTitle.text = text;
        
        *outY = [NSNumber numberWithFloat:CGRectGetMaxY(tempFrame)];
    }
}
//创建选项
-(void)setupOptionsWithFrame:(CGRect)frame
                        Type:(ItemOptionGroupType)type
                     Options:(NSArray *)options
                 RightAnswer:(NSString *)rightAnswer
                        OutY:(NSNumber **)outY {
    if(options && options.count > 0){
        if(!_optionsView){
            _optionsView = [[ItemOptionGroupView alloc] initWithFrame:frame];
            _optionsView.delegate = self;
            [self addSubview:_optionsView];
        }else{
            _optionsView.frame = frame;
        }
        ItemOptionGroupSource *dataSource = [ItemOptionGroupSource sourceOptions:options
                                                                   GroupType:type
                                                                    Selected:_itemSource.value
                                                               DisplayAnswer:_displayAnswer
                                                                          Answer:rightAnswer];
        //加载数据
        [_optionsView loadData:dataSource];
        //
        *outY = [NSNumber numberWithFloat:CGRectGetMaxY(_optionsView.frame)];
        //NSLog(@"setupOptionsWith-frame:%@ => %@, outY:%f",NSStringFromCGRect(frame), NSStringFromCGRect(_optionsView.frame), (*outY).floatValue);
    }
}
//创建判断题
-(void)setupJudgeWithFrame:(CGRect)frame Item:(PaperItem *)item OutY:(NSNumber **)outY {
    PaperItem *optionRight = [[PaperItem alloc] init],
    *optionWrong = [[PaperItem alloc] init];
    optionRight.code = [NSString stringWithFormat:@"%d",(int)PaperItemJudgeAnswerRight];
    optionRight.content = __kPaperItemJudgeAnswerRightTitle;
    
    optionWrong.code = [NSString stringWithFormat:@"%d",(int)PaperItemJudgeAnswerWrong];
    optionWrong.content = __kPaperItemJudgeAnswerWrongTitle;
    
    [self setupOptionsWithFrame:frame Type:ItemOptionGroupTypeSingle Options:@[optionRight,optionWrong] RightAnswer:item.answer OutY:outY];
    //答案及其解析
    [self setupAnswerWithOptions:@[optionRight,optionWrong] RightAnswer:item.answer Analysis:item.analysis OutY:outY];
}
//答案及其解析
-(void)setupAnswerWithOptions:(NSArray *)options RightAnswer:(NSString *)rightAnswer Analysis:(NSString *)analysis OutY:(NSNumber **)outY{
    if(_displayAnswer){
        NSMutableString *rightAnswerText = [NSMutableString string], *myAnswerText = [NSMutableString string];
        if(rightAnswer && rightAnswer.length > 0 && options && options.count > 0){
            for(PaperItem *item in options){
                if(!item || !item.code || item.code.length == 0) continue;
                if([rightAnswer containsString:item.code]){
                    [rightAnswerText appendFormat:@"%@ ", [item.content substringWithRange:NSMakeRange(0, 1)]];
                }
                if (_itemSource.value && _itemSource.value.length > 0 && [_itemSource.value containsString:item.code]) {
                    [myAnswerText appendFormat:@"%@ ",[item.content substringWithRange:NSMakeRange(0, 1)]];
                }
            }
        }
        
        CGRect tempFrame = CGRectMake(__k_itemcontentview_left,
                                      (*outY).floatValue + __k_itemcontentview_top + __k_itemcontentview_margin_max,
                                      CGRectGetWidth(self.frame) - (__k_itemcontentview_left + __k_itemcontentview_right),
                                      0);
        if(!_answerView){
            _answerView = [[ItemAnswerView alloc] initWithFrame:tempFrame];
            [self addSubview:_answerView];
        }else{
            _answerView.frame = tempFrame;
        }
        //加载数据
        ItemAnswerViewSource *answerSource = [ItemAnswerViewSource itemAnswer:myAnswerText RightAnswer:rightAnswerText Analysis:analysis];
        [_answerView loadData:answerSource];
    }else if(_answerView){
        CGRect temp = _answerView.frame;
        temp.size.height = 0;
        _answerView.frame = temp;
    }
    *outY = [NSNumber numberWithFloat:CGRectGetMaxY(_answerView.frame)];
}
//清空所有的数据
-(void)clean{
    //标题
    if(_lbTitle){
        _lbTitle.text = @"";
        _lbTitle.frame = CGRectZero;
    }
    //二级标题
    if(_lbSubTitle){
        _lbSubTitle.text = @"";
        _lbSubTitle.frame = CGRectZero;
    }
    //选项
    if(_optionsView){
        _optionsView.frame = CGRectZero;
    }
}
#pragma mark ItemOptionGroupDelegate
-(void)optionSelected:(ItemOptionView *)sender{
    if(self.itemDelegate && [self.itemDelegate respondsToSelector:@selector(selectedOption:)]){
        _itemSource.value = sender.optCode;
        [self.itemDelegate selectedOption:_itemSource];
    }
}
@end