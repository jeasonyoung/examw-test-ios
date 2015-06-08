//
//  MyProductRegModelTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyProductRegModelTableViewCell.h"
#import "AppConstants.h"
#import "MyProductRegModelCellFrame.h"
#import "ESTextField.h"
#import "EffectsUtils.h"
#import "UIColor+Hex.h"

//产品注册数据模型Cell成员变量
@interface MyProductRegModelTableViewCell (){
    NSString *_regCode;
    UILabel *_lbExamName,*_lbProductName;
    ESTextField *_tfRegCode;
    UIButton *_btnRegister;
}
@end
//产品注册数据模型Cell实现
@implementation MyProductRegModelTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //1.考试名称
        _lbExamName = [[UILabel alloc] init];
        _lbExamName.textAlignment = NSTextAlignmentCenter;
        _lbExamName.numberOfLines = 0;
        //2.产品名称
        _lbProductName = [[UILabel alloc] init];
        _lbProductName.textAlignment = NSTextAlignmentCenter;
        _lbProductName.numberOfLines = 0;
        //3.注册码
        _tfRegCode = [[ESTextField alloc] init];
        _tfRegCode.required = YES;
        _tfRegCode.keyboardType = UIKeyboardTypeNumberPad;
        _tfRegCode.clearButtonMode = UITextFieldViewModeWhileEditing;
        //4.按钮
        UIColor *btnColor = [UIColor colorWithHex:GLOBAL_REDCOLOR_HEX];
        _btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnRegister setTitle:@"产品注册码绑定" forState:UIControlStateNormal];
        [_btnRegister setTitleColor:btnColor forState:UIControlStateNormal];
        [_btnRegister addTarget:self action:@selector(btnRegisterClik:) forControlEvents:UIControlEventTouchUpInside];
        [EffectsUtils addBoundsRadiusWithView:_btnRegister BorderColor:btnColor BackgroundColor:nil];
        
        //添加到容器
        [self.contentView addSubview:_lbExamName];
        [self.contentView addSubview:_lbProductName];
        [self.contentView addSubview:_tfRegCode];
        [self.contentView addSubview:_btnRegister];
    }
    return self;
}

//按钮点击事件
-(void)btnRegisterClik:(UIButton *)sender{
    NSLog(@"注册按钮被点击:%@...",sender);
    if(_delegate && [_delegate respondsToSelector:@selector(productRegCell:btnClick:regCode:)]){
        if(_tfRegCode && [_tfRegCode validate]){
            NSString *regCodeValue = [_tfRegCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if(_regCode && ![_regCode isEqualToString:regCodeValue]){
                [_delegate productRegCell:self btnClick:sender regCode:regCodeValue];
            }
        }
    }
}

#pragma mark 加载数据模型Frame
-(void)loadModelCellFrame:(MyProductRegModelCellFrame *)cellFrame{
    if(cellFrame){
        //1.考试名称
        _lbExamName.font = cellFrame.examNameFont;
        _lbExamName.frame = cellFrame.examNameFrame;
        _lbExamName.text = cellFrame.examName;
        //2.产品名称
        _lbProductName.font = cellFrame.productNameFont;
        _lbProductName.frame = cellFrame.productNameFrame;
        _lbProductName.text = cellFrame.productName;
        //3.注册码
        _tfRegCode.font = cellFrame.productRegCodeFont;
        _tfRegCode.frame = cellFrame.productRegCodeFrame;
        _tfRegCode.placeholder = cellFrame.productRegCodePlaceholder;
        _tfRegCode.text = cellFrame.productRegCode;
        _regCode = cellFrame.productRegCode;
        //4.按钮
        _btnRegister.frame = cellFrame.btnRegisterFrame;
    }
}
@end
