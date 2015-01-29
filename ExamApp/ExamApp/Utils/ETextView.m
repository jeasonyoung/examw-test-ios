//
//  ETextView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ETextView.h"
#import "NSString+Size.h"
#import "UIColor+Hex.h"

#define __k_placehoderLabel_x 5//占位Label的x
#define __k_placehoderLabel_y 8//占位Label的y
//自定义文本输入控件成员变量
@interface ETextView(){
    UILabel *_placehoderLabel;
}
@end
//自定义文本输入控件实现类
@implementation ETextView
#pragma mark 初始化函数
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //设置背景透明
        self.backgroundColor = [UIColor clearColor];
        //添加一个显示提醒文字的Label(显示占位文字的label)
        _placehoderLabel = [[UILabel alloc] init];
        //设置支持多行格式
        _placehoderLabel.numberOfLines = 0;
        //设置清除背景色
        _placehoderLabel.backgroundColor = [UIColor clearColor];
        //把控件添加到View上
        [self addSubview:_placehoderLabel];
        //设置默认的占位文字的颜色为亮灰色
        self.placehoderColor = [UIColor lightGrayColor];
        //设置默认的字体为14号字体
        self.font = [UIFont systemFontOfSize:14];
        
        
        
        //注册一个通知中心，监听文字的改变
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(placehoderDidChange)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
        self.returnKeyType = UIReturnKeyDefault;//返回键类型
        self.keyboardType = UIKeyboardTypeDefault;//键盘类型
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 0.2;
        self.layer.borderColor = [[UIColor grayColor] CGColor];
    }
    return self;
}
#pragma mark 重载设置文字字体
-(void)setFont:(UIFont *)font{
    [super setFont:font];
    _placehoderLabel.font = font;
    //重新计算子控件的Frame
    [self setNeedsLayout];
}
#pragma mark 设置内容文字
-(void)setPlacehoder:(NSString *)placehoder{
    //设置占位文字
    _placehoderLabel.text =  _placehoder = placehoder;
    //重新计算文字的Frame
    [self setNeedsLayout];
}
#pragma mark 设置占位文字的颜色
-(void)setPlacehoderColor:(UIColor *)placehoderColor{
    _placehoderColor = placehoderColor;
    _placehoderLabel.textColor = placehoderColor;
}
#pragma mark 重载设置文字
-(void)setText:(NSString *)text{
    [super setText:text];
    [self placehoderDidChange];
}
#pragma mark重载计算 Frame
-(void)layoutSubviews{
    [super layoutSubviews];
    CGSize placehoderSize = [_placehoder sizeWithFont:self.font];
    CGFloat w = self.bounds.size.width - (2 * __k_placehoderLabel_x);
    if(w > placehoderSize.width){
        w = placehoderSize.width;
    }
    _placehoderLabel.frame = CGRectMake(__k_placehoderLabel_x, __k_placehoderLabel_y, w, placehoderSize.height);
}
#pragma mark 移除监听
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark 监听文字的改变
-(void)placehoderDidChange{
    //是否显示占位文字
    _placehoderLabel.hidden = self.text.length > 0;
}
@end
