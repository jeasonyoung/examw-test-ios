//
//  ItemAnswerView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/16.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemAnswerView.h"
#import "UIColor+Hex.h"
#import "NSString+Size.h"
#import "UIViewUtils.h"

//答案及其解析的数据源实现
@implementation ItemAnswerViewSource
#pragma mark 加载数据
-(void)loadMyAnswer:(NSString *)myAnswer RightAnswer:(NSString *)rightAnswer Analysis:(NSString *)analysis{
    _myAnswer = myAnswer;
    _rightAnswer = rightAnswer;
    _analysis = analysis;
}
#pragma mark 静态初始化
+(instancetype)itemAnswer:(NSString *)myAnswer RightAnswer:(NSString *)rightAnswer Analysis:(NSString *)analysis{
    ItemAnswerViewSource *source = [[ItemAnswerViewSource alloc] init];
    [source loadMyAnswer:myAnswer RightAnswer:rightAnswer Analysis:analysis];
    return source;
}
@end

#define __k_itemanswerview_top 5//顶部间距
#define __k_itemanswerview_left 5//左边间距
#define __k_itemanswerview_right 5//右边间距
#define __k_itemanswerview_bottom 7//底部间距
#define __k_itemanswerview_margin 3//

#define __k_itemanswerview_fontSize 14//字体大小
#define __k_itemanswerview_borderColor 0x00E5EE//答案边框颜色

#define __k_itemanswerview_my_title @"我的回答:"//
#define __k_itemanswerview_my_fontColor 0x0000FF//答案颜色

#define __k_itemanswerview_mytip_fontSize 13//字体大小
#define __k_itemanswerview_mytip_fontColor 0xFFFAFA//字体颜色

#define __k_itemanswerview_mytipright_title @" √ 答对了"//
#define __k_itemanswerview_mytipright_bgColor 0x008B00//背景色
#define __k_itemanswerview_mytipwrong_title @" × 答错了"//
#define __k_itemanswerview_mytipwrong_bgColor 0xFF0000//背景色

#define __k_itemanswerview_answer_title @"正确答案:"//
#define __k_itemanswerview_analysis_title @"答案解析"//

#define __k_itemanswerview_analysis_bgColor 0xFFEFDB//背景色

//试题答案及其解析成员变量
@interface ItemAnswerView (){
    UIFont *_font;
    
    UIColor *_colorTipRight,*_colorTipWrong;
    
    UILabel *_lbMyTitle,*_lbMy,*_lbMyTip;
    UILabel *_lbAnswerTitle,*_lbAnswer;
    UILabel *_lbAnalysisTitle,*_lbAnalysis;
    
    UIView *_analysisPanel;
}
@end
//试题答案及其解析实现
@implementation ItemAnswerView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _font = [UIFont systemFontOfSize:__k_itemanswerview_fontSize];
        
        _colorTipRight = [UIColor colorWithHex:__k_itemanswerview_mytipright_bgColor];
        _colorTipWrong = [UIColor colorWithHex:__k_itemanswerview_mytipwrong_bgColor];
       
        //初始化
        [self setupView];
        //添加边框
        [UIViewUtils addBoundsRadiusWithView:self
                                 BorderColor:[UIColor colorWithHex:__k_itemanswerview_borderColor]
                             BackgroundColor:nil];
    }
    return self;
}
//初始化
-(void)setupView{
    CGFloat width = CGRectGetWidth(self.frame) - (__k_itemanswerview_left + __k_itemanswerview_right);
    //第一行
    CGRect tempFrame = CGRectMake(__k_itemanswerview_left, __k_itemanswerview_top, width, 0);
    //我的回答
    CGSize titleSize = [__k_itemanswerview_my_title sizeWithFont:_font
                                               constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                                   lineBreakMode:NSLineBreakByWordWrapping];
    tempFrame.size = titleSize;
    _lbMyTitle = [[UILabel alloc]initWithFrame:tempFrame];
    _lbMyTitle.font = _font;
    _lbMyTitle.textAlignment = NSTextAlignmentLeft;
    _lbMyTitle.text = __k_itemanswerview_my_title;
    [self addSubview:_lbMyTitle];
    //回答内容
    tempFrame.origin.x = CGRectGetMaxX(tempFrame) + __k_itemanswerview_left;
    tempFrame.size.width = (titleSize.width/2);
    _lbMy = [[UILabel alloc]initWithFrame:tempFrame];
    _lbMy.font = _font;
    _lbMy.textAlignment = NSTextAlignmentLeft;
    _lbMy.textColor = [UIColor colorWithHex:__k_itemanswerview_my_fontColor];
    _lbMy.text = @" ";
    [self addSubview:_lbMy];
    //tip
    tempFrame.origin.x = CGRectGetMaxX(tempFrame) + __k_itemanswerview_left;
    UIFont *fontTip = [UIFont systemFontOfSize:__k_itemanswerview_mytip_fontSize];
    titleSize = [__k_itemanswerview_mytipwrong_title sizeWithFont:fontTip
                                                constrainedToSize:CGSizeMake(width - CGRectGetMaxX(tempFrame),CGFLOAT_MAX)
                                                    lineBreakMode:NSLineBreakByWordWrapping];
    tempFrame.size.width = titleSize.width;
    _lbMyTip = [[UILabel alloc] initWithFrame:tempFrame];
    _lbMyTip.font = fontTip;
    _lbMyTip.textColor = [UIColor colorWithHex:__k_itemanswerview_mytip_fontColor];
    _lbMyTip.backgroundColor = _colorTipWrong;
    _lbMyTip.textAlignment = NSTextAlignmentCenter;
    _lbMyTip.text = __k_itemanswerview_mytipwrong_title;
    [self addSubview:_lbMyTip];
    
    //第二行
    //正确答案
    tempFrame.origin.x = __k_itemanswerview_left;
    tempFrame.origin.y = CGRectGetMaxY(tempFrame) + __k_itemanswerview_top;
    tempFrame.size.width = width;
    
    titleSize = [__k_itemanswerview_answer_title sizeWithFont:_font
                                            constrainedToSize:CGSizeMake(width, 0)
                                                lineBreakMode:NSLineBreakByWordWrapping];
    tempFrame.size = titleSize;
    _lbAnswerTitle = [[UILabel alloc] initWithFrame:tempFrame];
    _lbAnswerTitle.font = _font;
    _lbAnswerTitle.textAlignment = NSTextAlignmentLeft;
    _lbAnswerTitle.text = __k_itemanswerview_answer_title;
    [self addSubview:_lbAnswerTitle];
    //答案
    tempFrame.origin.x = CGRectGetMaxX(tempFrame) + __k_itemanswerview_left;
    tempFrame.size.width = (width - titleSize.width);
    _lbAnswer = [[UILabel alloc] initWithFrame:tempFrame];
    _lbAnswer.font = _font;
    _lbAnswer.textAlignment = NSTextAlignmentLeft;
    _lbAnswer.text = @" ";
    [self addSubview:_lbAnswer];
    
    //第三行
    tempFrame.origin.x = __k_itemanswerview_left;
    tempFrame.origin.y = CGRectGetMaxY(tempFrame) + __k_itemanswerview_top;
    tempFrame.size = CGSizeMake(width, 0);
    
    //答案解析面板
    _analysisPanel = [[UIView alloc]initWithFrame:tempFrame];
    _analysisPanel.backgroundColor = [UIColor colorWithHex:__k_itemanswerview_analysis_bgColor];
    [self addSubview:_analysisPanel];
    //答案解析
    tempFrame.origin.x = __k_itemanswerview_left;
    tempFrame.origin.y = __k_itemanswerview_top;
    tempFrame.size.width -= (__k_itemanswerview_left + __k_itemanswerview_right);
    titleSize = [__k_itemanswerview_analysis_title sizeWithFont:_font
                                              constrainedToSize:CGSizeMake(CGRectGetWidth(tempFrame), CGFLOAT_MAX)
                                                  lineBreakMode:NSLineBreakByWordWrapping];
    tempFrame.size.height = titleSize.height;
    
    _lbAnalysisTitle = [[UILabel alloc] initWithFrame:tempFrame];
    _lbAnalysisTitle.font = _font;
    _lbAnalysisTitle.textAlignment = NSTextAlignmentLeft;
    _lbAnalysisTitle.text = __k_itemanswerview_analysis_title;
    [_analysisPanel addSubview:_lbAnalysisTitle];
    //
    tempFrame.origin.y = CGRectGetMaxY(tempFrame) + __k_itemanswerview_top;
    _lbAnalysis = [[UILabel alloc] initWithFrame:tempFrame];
    _lbAnalysis.font = _font;
    _lbAnalysis.textAlignment = NSTextAlignmentLeft;
    _lbAnalysis.numberOfLines = 0;
    _lbAnalysis.text = @" ";
    [_analysisPanel addSubview:_lbAnalysis];
    
    //重置高度
    [self resizeAnalysisSize];
 }

#pragma mark 加载数据
-(void)loadData:(ItemAnswerViewSource *)data{
    if(data){
        //我的答案
        _lbMy.text = (data.myAnswer ? data.myAnswer : @"");
        //正确答案
        _lbAnswer.text = (data.rightAnswer ? data.rightAnswer : @"");
        //答案提示
        _lbMyTip.backgroundColor = _colorTipWrong;
        _lbMyTip.text = __k_itemanswerview_mytipwrong_title;
        if(data.rightAnswer && data.rightAnswer.length > 0){
            if([data.rightAnswer isEqualToString:(data.myAnswer ? data.myAnswer : @"")]){
                _lbMyTip.backgroundColor = _colorTipRight;
                _lbMyTip.text = __k_itemanswerview_mytipright_title;
            }
        }
        //答案解析
        NSString *analysisText = data.analysis ? data.analysis : @"";
        CGSize textSize = [analysisText sizeWithFont:_lbAnalysis.font
                                   constrainedToSize:CGSizeMake(CGRectGetWidth(_lbAnalysis.frame), CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];
        //重置答案解析的高度
        CGRect tempFrame = _lbAnalysis.frame;
        tempFrame.size.height = textSize.height;
        _lbAnalysis.frame = tempFrame;
        //
         _lbAnalysis.text = analysisText;
        //重置高度
        [self resizeAnalysisSize];
    }
}
//重置答案解析的尺寸
-(void)resizeAnalysisSize{
    if(_lbAnalysis && _analysisPanel){
        //解析器面板
        CGRect tempFrame = _analysisPanel.frame;
        tempFrame.size.height = CGRectGetMaxY(_lbAnalysis.frame) + __k_itemanswerview_bottom;
        _analysisPanel.frame = tempFrame;
        //重置高度
        tempFrame = self.frame;
        tempFrame.size.height = CGRectGetMaxY(_analysisPanel.frame) + __k_itemanswerview_bottom;
        self.frame = tempFrame;
    }
}
//清空数据
-(void)clean{
    NSArray *arrays = @[_lbMy,_lbAnswer,_lbAnalysis];
    for(UILabel *lb in arrays){
        if(!lb) continue;
        lb.text = @"";
    }
}
@end
