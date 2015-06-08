//
//  FeedbackTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "FeedbackTableViewCell.h"
#import "AppConstants.h"

#import "ESTextView.h"

#import "EffectsUtils.h"
#import "UIColor+Hex.h"

#define __kFeedbackTableViewCell_top 10//顶部间距
#define __kFeedbackTableViewCell_left 10//左边间距
#define __kFeedbackTableViewCell_bottom 10//底部间距
#define __kFeedbackTableViewCell_right 10//右边间距

#define __kFeedbackTableViewCell_marginV 10//纵向间距

#define __kFeedbackTableViewCell_contentHeight 250//文本框高度
#define __kFeedbackTableViewCell_btnHeight 30//按钮高度

//意见反馈Cell成员变量
@interface FeedbackTableViewCell (){
    ESTextView *_tfContent;
    UIButton *_btn;
}
@end
//意见反馈Cell实现
@implementation FeedbackTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        CGFloat maxWidth = SCREEN_WIDTH - __kFeedbackTableViewCell_right, x = __kFeedbackTableViewCell_left,y = __kFeedbackTableViewCell_top;
        //字体
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        
        //内容框
        _tfContent = [[ESTextView alloc] initWithFrame:CGRectMake(x, y, maxWidth - x, __kFeedbackTableViewCell_contentHeight)];
        _tfContent.font = font;
        _tfContent.placehoder = @"请输入您的意见或者建议";
         
        y = CGRectGetMaxY(_tfContent.frame) + __kFeedbackTableViewCell_marginV;
        
        //按钮
        UIColor *borderColor = [UIColor colorWithHex:GLOBAL_REDCOLOR_HEX];
        _btn = [UIButton buttonWithType:UIButtonTypeSystem];
        _btn.frame = CGRectMake(x, y, maxWidth - x, __kFeedbackTableViewCell_btnHeight);
        _btn.titleLabel.font = font;
        [_btn setTitle:@"提交" forState:UIControlStateNormal];
        [_btn setTitleColor:borderColor forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [EffectsUtils addBoundsRadiusWithView:_btn BorderColor:borderColor BackgroundColor:[UIColor whiteColor]];
        
        //添加到容器
        [self.contentView addSubview:_tfContent];
        [self.contentView addSubview:_btn];
    }
    return self;
}

//按钮事件响应
-(void)btnClick:(UIButton *)sender{
    //键盘关闭
    [self endEditing:YES];
    //事件代理
    if(_delegate && [_delegate respondsToSelector:@selector(feedBackCell:click:body:)]){
        NSString *contentValue = [_tfContent.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [_delegate feedBackCell:self click:sender body:contentValue];
    }
}

#pragma mark 行高
+(CGFloat)cellHeight{
    return __kFeedbackTableViewCell_top + __kFeedbackTableViewCell_contentHeight + __kFeedbackTableViewCell_marginV + __kFeedbackTableViewCell_btnHeight + __kFeedbackTableViewCell_bottom;
}
@end
