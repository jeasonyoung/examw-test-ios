//
//  MyUserRegisterTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/7.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MyUserRegisterTableViewCell.h"
#import "AppConstants.h"

#import "ESTextField.h"

#import "EffectsUtils.h"
#import "UIColor+Hex.h"

#import "UserRegisterModel.h"

#define __kMyUserRegisterTableViewCell_top 10//顶部间距
#define __kMyUserRegisterTableViewCell_left 10//左边间距
#define __kMyUserRegisterTableViewCell_bottom 10//底部间距
#define __kMyUserRegisterTableViewCell_right 10//右边间距

#define __kMyUserRegisterTableViewCell_marginV 10//纵向间距
#define __kMyUserRegisterTableViewCell_marginH 2//横向间距

#define __kMyUserRegisterTableViewCell_height 30//输入框高度
#define __kMyUserRegisterTableViewCell_labelWidth 70//输入框高度

//用户注册Cell成员变量
@interface MyUserRegisterTableViewCell ()<UITextFieldDelegate>{
    UserRegisterModel *_userRegisterModel;
}
@end
//用户注册Cell实现
@implementation MyUserRegisterTableViewCell

#pragma mark 重载行高
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //初始化数据模型
        _userRegisterModel = [[UserRegisterModel alloc] init];
        //初始化
        [self setupInits];
    }
    return self;
}

//初始化
-(void)setupInits{
    CGFloat maxWidth = SCREEN_WIDTH - __kMyUserRegisterTableViewCell_right, x = 0, y = __kMyUserRegisterTableViewCell_top;
    //
    NSArray *lables = @[@"用户名:",@"密码:",@"重复密码:",@"姓名:",@"电子邮箱:",@"手机号码:"];
    NSArray *placeholders = @[@"请输入用户名",@"请输入密码",@"请输入重复密码",@"请输入姓名",@"请输入电子邮箱",@"请输入手机号码"];
    //
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    //
    NSUInteger count = lables.count;
    NSMutableArray *lbArrays = [NSMutableArray arrayWithCapacity:count], *tfArrays = [NSMutableArray arrayWithCapacity:count];
    //
    for(NSUInteger i = 0; i < count; i++){
        //定义x,y坐标
        x = __kMyUserRegisterTableViewCell_left;
        //创建名称
        UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, y, __kMyUserRegisterTableViewCell_labelWidth, __kMyUserRegisterTableViewCell_height)];
        lbTitle.font = font;
        lbTitle.textAlignment = NSTextAlignmentRight;
        lbTitle.text = [lables objectAtIndex:i];
        //lbTitle.backgroundColor = [UIColor redColor];
        [lbArrays addObject:lbTitle];
        x = CGRectGetMaxX(lbTitle.frame) + __kMyUserRegisterTableViewCell_marginH;
        //创建输入框
        ESTextField *tf = [[ESTextField alloc] initWithFrame:CGRectMake(x, y, maxWidth - x, __kMyUserRegisterTableViewCell_height)];
        tf.required = YES;
        tf.tag = i;
        tf.delegate = self;
        tf.placeholder = [placeholders objectAtIndex:i];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        switch (i) {
            case 1://密码
            case 2://重复密码
            {
                tf.secureTextEntry = YES;
                break;
            }
            case 4:{//电子邮箱
                tf.isEmailField = YES;
                break;
            }
            case 5:{//手机号码
                tf.keyboardType = UIKeyboardTypePhonePad;
                break;
            }
        }
        [tfArrays addObject:tf];
        //
        y = CGRectGetMaxY(tf.frame) + __kMyUserRegisterTableViewCell_marginV;
    }
    //添加到面板
    for(UILabel *lb in lbArrays){
        if(!lb)continue;
        [self.contentView addSubview:lb];
    }
    for(ESTextField *tf in tfArrays){
        if(!tf)continue;
        [self.contentView addSubview:tf];
    }
    //添加按钮
    x = __kMyUserRegisterTableViewCell_left;
    UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeSystem];
    [btnSubmit setTitle:@"注册" forState:UIControlStateNormal];
    [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSubmit.frame = CGRectMake(x, y + 2* __kMyUserRegisterTableViewCell_marginV, maxWidth - x, __kMyUserRegisterTableViewCell_height);
    [btnSubmit addTarget:self action:@selector(btnRegisterClick:) forControlEvents:UIControlEventTouchUpInside];
    UIColor *color = [UIColor colorWithHex:0x1E90FF];
    [EffectsUtils addBoundsRadiusWithView:btnSubmit BorderColor:color BackgroundColor:color];
    [self.contentView addSubview:btnSubmit];
    //实际行高
    NSLog(@">>>实际行高:%f....", CGRectGetMaxY(btnSubmit.frame) + __kMyUserRegisterTableViewCell_marginV);
}

//注册按钮点击事件处理
-(void)btnRegisterClick:(UIButton *)sender{
    NSLog(@"按钮点击事件:%@...",sender);
    //验证输入
    if([self validateInputInView:sender.superview]){
        if(_delegate && [_delegate respondsToSelector:@selector(userRegisterBtnClick:registerModel:)]){
            [_delegate userRegisterBtnClick:sender registerModel:_userRegisterModel];
        }
    }
}

//验证输入
-(BOOL)validateInputInView:(UIView*)view{
    for(UIView *subView in view.subviews){
        if ([subView isKindOfClass:[UIScrollView class]]){
            return [self validateInputInView:subView];
        }
        if ([subView isKindOfClass:[ESTextField class]]){
            if (![(MHTextField*)subView validate]){
                return NO;
            }
            [self loadRegisterModelValueWithInput:(ESTextField *)subView];
        }
    }
    return YES;
}

//赋予
-(void)loadRegisterModelValueWithInput:(ESTextField *)tf{
    if(_userRegisterModel && tf){
        NSString *value = [tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(value.length == 0)return;
        switch (tf.tag) {
            case 0:{//用户名
                _userRegisterModel.account = value;
                break;
            }
            case 1:{//密码
                _userRegisterModel.password = value;
                break;
            }
            case 2:{//重复密码
                break;
            }
            case 3:{//姓名
                _userRegisterModel.username = value;
                break;
            }
            case 4:{//电子邮箱
                _userRegisterModel.email = value;
                break;
            }
            case 5:{//手机号码
                _userRegisterModel.phone = value;
                break;
            }
            default:
                break;
        }
        
    }
}

#pragma mark UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing[%@]->%d=>%@...",textField, (int)textField.tag, textField.text);
    if(![textField isKindOfClass:[ESTextField class]] || !_userRegisterModel)return;
    if((textField.tag == 2) && (![_userRegisterModel.password isEqualToString:textField.text])){
        ((ESTextField *)textField).text = @"";
        ((ESTextField *)textField).placeholder = @"密码不一致，请重新输入!";
        return;
    }
    [self loadRegisterModelValueWithInput:(ESTextField *)textField];
    
}

#pragma mark 行高
+(CGFloat)cellHeight{
    return 300;
}
@end
