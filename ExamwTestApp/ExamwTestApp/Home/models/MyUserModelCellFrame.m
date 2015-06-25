//
//  MyUserModel.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyUserModelCellFrame.h"
#import "UserAccount.h"

#import "AppConstants.h"

#define __kMyUserModelCellFrame_top 15//顶部间距
#define __kMyUserModelCellFrame_left 15//左边间距
#define __kMyUserModelCellFrame_bottom 15//底部间距
#define __kMyUserModelCellFrame_right 15//右边间距

#define __kMyUserModelCellFrame_marginV 10//纵向间距
#define __kMyUserModelCellFrame_marginH 10//横向间距

#define __kMyUserModelCellFrame_imgWidth 70//头像宽度
#define __kMyUserModelCellFrame_imgHeight 70//头像高度

#define __kMyUserModelCellFrame_title @"您还没有登录"//未登录标题
#define __kMyUserModelCellFrame_btnRegister @"注册"//注册
#define __kMyUserModelCellFrame_btnLogin @"登录"//登录
#define __kMyUserModelCellFrame_noRegCode @"当前产品免费使用"//

#define __kMyUserModelCellFrame_btnWidth 100//按钮宽度
#define __kMyUserModelCellFrame_btnHeight 32//按钮高度

//用户信息数据模型CellFrame实现
@implementation MyUserModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _titleFont = [AppConstants globalListFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        _regCodeFont = [AppConstants globalListThirdFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        _userLoginFont = [AppConstants globalListSubFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _userRegFont = _userLoginFont;
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(UserAccount *)model{
    _model = model;
    //重置Frame
    _imgFrame = _titleFrame = _regCodeFrame = CGRectZero;
    _userRegFrame = _userLoginFrame = CGRectZero;
    //
    CGFloat width = SCREEN_WIDTH,maxWith = width - __kMyUserModelCellFrame_right,
        x = __kMyUserModelCellFrame_left, y = __kMyUserModelCellFrame_top;
    if(model){//用户已登陆
        //图像
        _img = [UIImage imageNamed:@"head.png"];
        if(_img){
            _imgFrame = CGRectMake(x, y, __kMyUserModelCellFrame_imgWidth,
                               __kMyUserModelCellFrame_imgHeight);
            x = CGRectGetMaxX(_imgFrame) + __kMyUserModelCellFrame_marginH;
        }
        //
        CGSize titleSize = CGSizeZero,regCodeSize = CGSizeZero;
        //用户名
        _title = _model.username;
        //注册码
        _regCode = _model.regCode;
        if(_title && _title.length > 0){
            titleSize = [_title boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                             options:STR_SIZE_OPTIONS
                                          attributes:@{NSFontAttributeName : _titleFont}
                                             context:nil].size;
            //
            if(!_regCode || _regCode.length == 0){
                _regCode = __kMyUserModelCellFrame_noRegCode;
            }
            regCodeSize = [_regCode boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                 options:STR_SIZE_OPTIONS
                                              attributes:@{NSFontAttributeName : _regCodeFont}
                                                 context:nil].size;
        }
        //
        CGFloat rightHeight = titleSize.height + __kMyUserModelCellFrame_marginV + regCodeSize.height;
        if(rightHeight > CGRectGetHeight(_imgFrame)){//右边高于左边，左边要下移
            _imgFrame.origin.y +=  (rightHeight - CGRectGetHeight(_imgFrame))/2;
            _cellHeight = y + rightHeight + __kMyUserModelCellFrame_bottom;
        }else{//左边高于右边，则右边y下移
            y += (CGRectGetHeight(_imgFrame) - rightHeight)/2;
            _cellHeight = CGRectGetMaxY(_imgFrame) + __kMyUserModelCellFrame_bottom;
        }
        //用户名Frame
        if(!CGSizeEqualToSize(titleSize, CGSizeZero)){
            _titleFrame = CGRectMake(x, y, titleSize.width, titleSize.height);
            y = CGRectGetMaxY(_titleFrame) + __kMyUserModelCellFrame_marginV;
        }
        //注册码
        if(!CGSizeEqualToSize(regCodeSize, CGSizeZero)){
            _regCodeFrame = CGRectMake(x, y, regCodeSize.width, regCodeSize.height);
        }
    }else{//未登录
        _title = __kMyUserModelCellFrame_title;
        CGSize titleSize = [_title boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                             attributes:@{NSFontAttributeName : _titleFont}
                                                context:nil].size;
        _titleFrame = CGRectMake((width - titleSize.width)/2, y, titleSize.width, titleSize.height);
        y = CGRectGetMaxY(_titleFrame) + __kMyUserModelCellFrame_marginV;
        //
        _userReg = __kMyUserModelCellFrame_btnRegister;
        _userLogin = __kMyUserModelCellFrame_btnLogin;
        //
        CGFloat padding = (maxWith - x - __kMyUserModelCellFrame_marginH - __kMyUserModelCellFrame_btnWidth *2)/2;
        _userRegFrame = CGRectMake(x + padding, y,
                                   __kMyUserModelCellFrame_btnWidth, __kMyUserModelCellFrame_btnHeight);
        x = CGRectGetMaxX(_userRegFrame) + __kMyUserModelCellFrame_marginH;
        _userLoginFrame = CGRectMake(x, y, __kMyUserModelCellFrame_btnWidth,
                                     __kMyUserModelCellFrame_btnHeight);
        //行高
        _cellHeight = CGRectGetMaxY(_userLoginFrame) + __kMyUserModelCellFrame_bottom;
    }
}
@end
