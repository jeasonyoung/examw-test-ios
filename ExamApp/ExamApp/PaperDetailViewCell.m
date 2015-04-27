//
//  PaperDetailCellTableViewCell.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperDetailViewCell.h"
#import "PaperDetailModel.h"

#import "UIViewUtils.h"
#import "UIColor+Hex.h"

//试卷明细Cell实现
@implementation PaperDetailViewCell
#pragma mark 初始化
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]){
        
    }
    return self;
}
#pragma mark 重载设置选中事件
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark 加载数据Frame
-(void)loadModelFrame:(PaperDetailModelFrame *)modelFrame{
    
}
@end

#define __kPaperDetailTitleViewCell_borderColor 0xdedede//边框颜色
#define __kPaperDetailTitleViewCell_bgColor 0xf1f1f1//背景色
//试卷明细标题Cell成员变量
@interface PaperDetailTitleViewCell (){
    UILabel *_content;
}
@end
//试卷明细标题Cell实现
@implementation PaperDetailTitleViewCell
#pragma mark 初始化
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithReuseIdentifier:reuseIdentifier]){
        _content = [[UILabel alloc]init];
        _content.textAlignment = NSTextAlignmentCenter;
        _content.numberOfLines = 0;
        
        UIColor *borderColor = [UIColor colorWithHex:__kPaperDetailTitleViewCell_borderColor];
        UIColor *bgColor = [UIColor colorWithHex:__kPaperDetailTitleViewCell_bgColor];
        [UIViewUtils addBoundsRadiusWithView:_content BorderColor:borderColor BackgroundColor:bgColor];
        [self addSubview:_content];
    }
    return self;
}
#pragma mark 加载模型Frame
-(void)loadModelFrame:(PaperDetailModelFrame *)modelFrame{
    if(modelFrame){
        _content.frame = modelFrame.titleFrame;
        _content.font = modelFrame.font;
        _content.text = modelFrame.title;
    }
}
@end

//试卷明细按钮Cell成员变量
#define __kPaperDetailBtnsViewCell_margin 15//
#define __kPaperDetailBtnsViewCell_btnStart @"开始考试"
#define __kPaperDetailBtnsViewCell_btnContinue @"继续考试"
#define __kPaperDetailBtnsViewCell_btnView @"查看成绩"
#define __kPaperDetailBtnsViewCell_btnRenew @"重新开始"
#define __kPaperDetailBtnsViewCell_btnBgNormal 0x3277ec//
#define __kPaperDetailBtnsViewCell_btnBghighlight 0x008B00//
#define __kPaperDetailBtnsViewCell_btnBorderColor 0xdedede
@interface PaperDetailBtnsViewCell (){
    UIColor *_borderColor,*_bgNormalColor,*_bgHiglightColor;
    UIButton *_btn1,*_btn2;
}
@end
//试卷明细按钮Cell实现
@implementation PaperDetailBtnsViewCell
#pragma mark 初始化
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithReuseIdentifier:reuseIdentifier]){
        _borderColor = [UIColor colorWithHex:__kPaperDetailBtnsViewCell_btnBorderColor];
        _bgNormalColor = [UIColor colorWithHex:__kPaperDetailBtnsViewCell_btnBgNormal];
        _bgHiglightColor = [UIColor colorWithHex:__kPaperDetailBtnsViewCell_btnBghighlight];
        //
        _btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_btn1];
        [UIViewUtils addBoundsRadiusWithView:_btn1 BorderColor:_borderColor BackgroundColor:nil];
        [_btn1 addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_btn1 setTitleColor:_bgNormalColor forState:UIControlStateNormal];
        [_btn1 setTitleColor:_bgHiglightColor forState:UIControlStateHighlighted];
        //
        _btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_btn2];
        [UIViewUtils addBoundsRadiusWithView:_btn2 BorderColor:_borderColor BackgroundColor:nil];
        [_btn2 addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_btn2 setTitleColor:_bgNormalColor forState:UIControlStateNormal];
        [_btn2 setTitleColor:_bgHiglightColor forState:UIControlStateHighlighted];
    }
    return self;
}
//添加事件
-(void)btnOnClick:(UIButton *)sender{
    if(sender && self.delegate && [self.delegate respondsToSelector:@selector(detailViewCell:didButtonClick:)]){
        [self.delegate detailViewCell:self didButtonClick:sender];
    }
}
#pragma mark 加载模型Frame
-(void)loadModelFrame:(PaperDetailModelFrame *)modelFrame{
    if(modelFrame){
        _btn1.titleLabel.font = _btn2.titleLabel.font = modelFrame.font;
        NSString *content = (modelFrame.titleAttri ? [modelFrame.titleAttri string] : nil);
        if(!content || content.length == 0){//一个按钮
            [self setupSignWithRect:modelFrame.titleFrame];
        }else{//两个按钮
            [self setupDoubleWithRect:modelFrame.titleFrame content:content];
        }
    }
}
//加载一个按钮
-(void)setupSignWithRect:(CGRect)rect{
    //隐藏第二个按钮
    if(_btn2){
        _btn2.frame = CGRectZero;
        _btn2.hidden = YES;
    }
    //第一个按钮
    _btn1.frame = rect;
    [_btn1 setTitle:__kPaperDetailBtnsViewCell_btnStart forState:UIControlStateNormal];
    _btn1.tag = __kPaperDetailViewCell_btnTypeStart;
}
//加载两个按钮
-(void)setupDoubleWithRect:(CGRect)rect content:(NSString *)content{
    CGFloat width = (CGRectGetWidth(rect) - __kPaperDetailBtnsViewCell_margin)/2;
    CGRect btn1Frame = rect;
    btn1Frame.size.width = width;
    _btn1.frame = btn1Frame;
    _btn1.hidden = NO;
    
    CGRect btn2Frame = btn1Frame;
    btn2Frame.origin.x = CGRectGetMaxX(btn1Frame) + __kPaperDetailBtnsViewCell_margin;
     _btn2.frame = btn2Frame;
     _btn2.hidden = NO;
    
    if([content hasSuffix:@"0"]){//0未做完
        //继续考试
        [_btn1 setTitle:__kPaperDetailBtnsViewCell_btnContinue forState:UIControlStateNormal];
        _btn1.tag = __kPaperDetailViewCell_btnTypeContinue;
        
        //重新开始
        [_btn2 setTitle:__kPaperDetailBtnsViewCell_btnRenew forState:UIControlStateNormal];
        _btn2.tag = __kPaperDetailViewCell_btnTypeReview;
    }else{//1已做完
        //查看成绩
        [_btn1 setTitle:__kPaperDetailBtnsViewCell_btnView forState:UIControlStateNormal];
        _btn1.tag = __kPaperDetailViewCell_btnTypeView;
        
        //开始考试
        [_btn2 setTitle:__kPaperDetailBtnsViewCell_btnStart forState:UIControlStateNormal];
        _btn2.tag = __kPaperDetailViewCell_btnTypeStart;
    }
}
@end

//试卷明细描述Cell成员变量
@interface PaperDetailDescViewCell (){
    UIColor *_borderColor;
    UILabel *_content;
}
@end
//试卷明细描述Cell实现
@implementation PaperDetailDescViewCell
#pragma mark 初始化
-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithReuseIdentifier:reuseIdentifier]){
         _borderColor = [UIColor colorWithHex:__kPaperDetailBtnsViewCell_btnBorderColor];
        _content = [[UILabel alloc]init];
        _content.textAlignment = NSTextAlignmentLeft;
        _content.numberOfLines = 0;
        [self addSubview:_content];
        [UIViewUtils addBoundsRadiusWithView:_content BorderColor:_borderColor BackgroundColor:nil];
    }
    return self;
}
#pragma mark 加载模型Frame
-(void)loadModelFrame:(PaperDetailModelFrame *)modelFrame{
    if(modelFrame){
        _content.frame = modelFrame.titleFrame;
        _content.attributedText = modelFrame.titleAttri;
    }
}
@end
