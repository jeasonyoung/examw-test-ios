//
//  MyUserModelTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyUserModelTableViewCell.h"
#import "MyUserModelCellFrame.h"

#import "EffectsUtils.h"
#import "UIColor+Hex.h"
//用户信息Cell成员变量
@interface MyUserModelTableViewCell (){
    UIImageView *_imgView;
    UILabel *_lbTitle,*_lbRegCode;
    UIButton *_btnUserRegister,*_btnUserLogin;
}
@end
//用户信息Cell实现
@implementation MyUserModelTableViewCell

#pragma mark 重置初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //定义颜色
        UIColor *borderColor = [UIColor colorWithHex:0xB4CDCD];
        
        //图标
        _imgView = [[UIImageView alloc] init];
        //标题
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.textAlignment = NSTextAlignmentLeft;
        _lbTitle.numberOfLines = 0;
        //注册码
        _lbRegCode = [[UILabel alloc] init];
        _lbRegCode.textAlignment = NSTextAlignmentLeft;
        _lbRegCode.numberOfLines = 0;
        _lbRegCode.textColor = borderColor;
        _lbRegCode.userInteractionEnabled = YES;
        //_lbRegCode.backgroundColor = [UIColor grayColor];
        [_lbRegCode addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeRegCode:)]];
        //
        
        //注册按钮
        _btnUserRegister = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btnUserRegister addTarget:self action:@selector(btnRegisterClick:) forControlEvents:UIControlEventTouchUpInside];
        [EffectsUtils addBoundsRadiusWithView:_btnUserRegister BorderColor:borderColor BackgroundColor:nil];
        //登录按钮
        _btnUserLogin = [UIButton buttonWithType:UIButtonTypeSystem];
        [_btnUserLogin addTarget:self action:@selector(btnLoginClick:) forControlEvents:UIControlEventTouchUpInside];
        [EffectsUtils addBoundsRadiusWithView:_btnUserLogin BorderColor:borderColor BackgroundColor:nil];
        //
        [self.contentView addSubview:_imgView];
        [self.contentView addSubview:_lbTitle];
        [self.contentView addSubview:_lbRegCode];
        [self.contentView addSubview:_btnUserRegister];
        [self.contentView addSubview:_btnUserLogin];
    }
    return self;
}

#pragma mark 加载数据模型Cell Frame
-(void)loadModelCellFrame:(MyUserModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    //图标
    _imgView.image = cellFrame.img;
    _imgView.frame = cellFrame.imgFrame;
    //标题
    _lbTitle.frame = cellFrame.titleFrame;
    _lbTitle.font = cellFrame.titleFont;
    _lbTitle.text = cellFrame.title;
    //注册码
    _lbRegCode.frame = cellFrame.regCodeFrame;
    _lbRegCode.font = cellFrame.regCodeFont;
    _lbRegCode.text = cellFrame.regCode;
    //注册按钮
    if(cellFrame.userReg && cellFrame.userReg.length > 0){
        _btnUserRegister.frame = cellFrame.userRegFrame;
        _btnUserRegister.titleLabel.font = cellFrame.userRegFont;
        [_btnUserRegister setTitle:cellFrame.userReg forState:UIControlStateNormal];
    }else{
        _btnUserRegister.frame = cellFrame.userRegFrame;
    }
    //登录按钮
    if(cellFrame.userLogin && cellFrame.userLogin.length > 0){
        _btnUserLogin.frame = cellFrame.userLoginFrame;
        _btnUserLogin.titleLabel.font = cellFrame.userLoginFont;
        [_btnUserLogin setTitle:cellFrame.userLogin forState:UIControlStateNormal];
    }else{
        _btnUserLogin.frame = cellFrame.userLoginFrame;
    }
}

//注册按钮事件
-(void)btnRegisterClick:(UIButton *)sender{
    NSLog(@"注册按钮...");
    if(_delegate && [_delegate respondsToSelector:@selector(userRegisterClick:)]){
        [_delegate userRegisterClick:sender];
    }
}
//登录按钮事件
-(void)btnLoginClick:(UIButton *)sender{
    NSLog(@"登录按钮...");
    if(_delegate && [_delegate respondsToSelector:@selector(userLoginClick:)]){
        [_delegate userLoginClick:sender];
    }
}
//变更注册码
-(void)changeRegCode:(id)sender{
    NSLog(@"变更注册码...");
    if(_delegate && [_delegate respondsToSelector:@selector(changeRegCode:)]){
        [_delegate changeRegCode:sender];
    }
}
@end
