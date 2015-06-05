//
//  MyUserLoginTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyUserLoginTableViewCell.h"
#import "ESTextField.h"
#import "AppConstants.h"
#import "EffectsUtils.h"
#import "UIColor+Hex.h"

#define __kMyUserLoginTableViewCell_top 10//顶部间距
#define __kMyUserLoginTableViewCell_left 10//左边间距
#define __kMyUserLoginTableViewCell_bottom 10//底部间距
#define __kMyUserLoginTableViewCell_right 10//右边间距

#define __kMyUserLoginTableViewCell_textFieldHeight 30//输入框高度

#define __kMyUserLoginTableViewCell_marginV 10//纵向间距
#define __kMyUserLoginTableViewCell_marginH 10//横向间距

#define __kMyUserLoginTableViewCell_cellHeight 130//行高
//用户登录Cell成员变量
@interface MyUserLoginTableViewCell (){
    ESTextField *_tfAccount,*_tfPassword;
}
@end
//用户登录Cell实现
@implementation MyUserLoginTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        CGFloat maxWith = SCREEN_WIDTH - __kMyUserLoginTableViewCell_right, x = __kMyUserLoginTableViewCell_left,
                y = __kMyUserLoginTableViewCell_top, height = __kMyUserLoginTableViewCell_textFieldHeight;
        
        UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        
        //用户名(第1行1列)
        NSString *account = @"用户名:";
        CGSize accountSize = [account boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                   options:STR_SIZE_OPTIONS
                                                attributes:@{NSFontAttributeName : font}
                                                   context:nil].size;
        UILabel *lbAccount = [[UILabel alloc] initWithFrame:CGRectMake(x, y, accountSize.width, height)];
        lbAccount.textAlignment = NSTextAlignmentRight;
        lbAccount.font = font;
        lbAccount.text = account;
        x = CGRectGetMaxX(lbAccount.frame) + __kMyUserLoginTableViewCell_marginH;
        //用户名(第1行2列)
        _tfAccount = [[ESTextField alloc] initWithFrame:CGRectMake(x, y, maxWith - x, height)];
        _tfAccount.font = font;
        _tfAccount.placeholder = @"请输入用户名";
        _tfAccount.required = YES;
        _tfAccount.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfAccount.tag = 0;
        y = CGRectGetMaxY(_tfAccount.frame) + __kMyUserLoginTableViewCell_marginV;
        
        //密码(第2行1列)
        x = __kMyUserLoginTableViewCell_left;
        UILabel *lbPassword = [[UILabel alloc] initWithFrame:CGRectMake(x, y, CGRectGetWidth(lbAccount.frame), height)];
        lbPassword.textAlignment = NSTextAlignmentRight;
        lbPassword.font = font;
        lbPassword.text = @"密码:";
        x = CGRectGetMaxX(lbPassword.frame) + __kMyUserLoginTableViewCell_marginH;
        //密码(第2行2列)
        _tfPassword = [[ESTextField alloc] initWithFrame:CGRectMake(x, y, maxWith - x, height)];
        _tfPassword.font = font;
        _tfPassword.placeholder = @"请输入密码";
        _tfPassword.required = YES;
        _tfPassword.secureTextEntry = YES;
        _tfPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
        _tfPassword.tag = 0;
        y = CGRectGetMaxY(_tfPassword.frame) + __kMyUserLoginTableViewCell_marginV;
        
        //登录按钮(第3行1列)
        UIColor *borderColor = [UIColor colorWithHex:0x1E90FF];
        x = __kMyUserLoginTableViewCell_left;
        CGFloat width = (maxWith - x - __kMyUserLoginTableViewCell_marginH*3)/2;
        CGFloat padding = (maxWith - x)/2 - width;
        UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeSystem];
        btnSubmit.frame = CGRectMake(x + padding, y, width, height);
        [btnSubmit setTitle:@"登录" forState:UIControlStateNormal];
        [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnSubmit addTarget:self action:@selector(btnSubmitClick:) forControlEvents:UIControlEventTouchUpInside];
        [EffectsUtils addBoundsRadiusWithView:btnSubmit BorderColor:borderColor BackgroundColor:borderColor];
        
        //注册按钮(第3行2列)
        UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeSystem];
        btnRegister.frame = CGRectMake((maxWith - x)/2 + padding, y, width, height);
        [btnRegister setTitle:@"注册" forState:UIControlStateNormal];
        [btnRegister setTitleColor:borderColor forState:UIControlStateNormal];
        [btnRegister addTarget:self action:@selector(btnRegisterClick:) forControlEvents:UIControlEventTouchUpInside];
        [EffectsUtils addBoundsRadiusWithView:btnRegister BorderColor:borderColor BackgroundColor:[UIColor whiteColor]];
        
        NSLog(@"cellheight:%f",CGRectGetMaxY(btnRegister.frame) + __kMyUserLoginTableViewCell_bottom);
        
        //添加到容器
        [self.contentView addSubview:lbAccount];
        [self.contentView addSubview:_tfAccount];
        [self.contentView addSubview:lbPassword];
        [self.contentView addSubview:_tfPassword];
        [self.contentView addSubview:btnSubmit];
        [self.contentView addSubview:btnRegister];
    }
    return self;
}

//登录按钮点击
-(void)btnSubmitClick:(UIButton *)sender{
    if(!_tfAccount || ![_tfAccount validate]) return;
    if(!_tfPassword || ![_tfPassword validate])return;
    
    if(_delegate && [_delegate respondsToSelector:@selector(userLoginCell:loginClick:account:password:)]){
        NSString *account = [_tfAccount.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
        *pwd = [_tfPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [_delegate userLoginCell:self loginClick:sender account:account password:pwd];
    }
}
//注册按钮点击
-(void)btnRegisterClick:(UIButton *)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(userLoginCell:registerClick:)]){
        [_delegate userLoginCell:self registerClick:sender];
    }
}
#pragma mark 加载账号
-(void)loadAccount:(NSString *)account{
    if(_tfAccount){
        _tfAccount.text = account;
    }
}

#pragma mark 行高
+(CGFloat)cellHeight{
    return __kMyUserLoginTableViewCell_cellHeight;
}
@end
