//
//  PaperButtonTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperButtonTableViewCell.h"
#import "PaperButtonModelCellFrame.h"

#import "AppConstants.h"
#import "UIColor+Hex.h"
#import "EffectsUtils.h"

//试卷按钮Cell成员变量
@interface PaperButtonTableViewCell (){
    UIButton *_btn1,*_btn2;
}
@end
//试卷按钮Cell实现
@implementation PaperButtonTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //边框颜色
        UIColor *color = [UIColor colorWithHex:GLOBAL_REDCOLOR_HEX];
        //按钮1
        _btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [EffectsUtils addBoundsRadiusWithView:_btn1 BorderColor:color BackgroundColor:color];
        //按钮2
        _btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn2.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_btn2 setTitleColor:color forState:UIControlStateNormal];
        [_btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [EffectsUtils addBoundsRadiusWithView:_btn2 BorderColor:color BackgroundColor:nil];
        //添加到容器
        [self.contentView addSubview:_btn1];
        [self.contentView addSubview:_btn2];
    }
    return self;
}

#pragma mark 加载数据模型Frame
-(void)loadModelCellFrame:(PaperButtonModelCellFrame *)cellFrame{
    NSLog(@"加载试卷明细按钮数据模型Frame...");
    if(!cellFrame)return;
    //按钮1
    [_btn1 setTitle:cellFrame.btn1Title forState:UIControlStateNormal];
    _btn1.titleLabel.font = cellFrame.btnFont;
    _btn1.frame = cellFrame.btn1Frame;
    _btn1.tag = cellFrame.btn1Tag;
    //按钮2
    [_btn2 setTitle:cellFrame.btn2Title forState:UIControlStateNormal];
    _btn2.titleLabel.font = cellFrame.btnFont;
    _btn2.frame = cellFrame.btn2Frame;
    _btn2.tag = cellFrame.btn2Tag;
}
//按钮点击事件
-(void)btnClick:(UIButton *)sender{
    NSLog(@"点击:%@=>%d",sender, (int)sender.tag);
    if(_btnClick){
        _btnClick(sender.tag);
    }
}
@end
