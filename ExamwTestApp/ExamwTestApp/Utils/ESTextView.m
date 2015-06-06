//
//  ESTextView.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ESTextView.h"

#import "AppConstants.h"

#define __kESTextView_placehoderX 5//占位Label的x
#define __kESTextView_placehoderY 8//占位Label的y

//多行文本输入扩展成员变量
@interface ESTextView (){
     UILabel *_placehoderLabel;
}
@end
//多行文本输入扩展实现
@implementation ESTextView

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        [self setupInit];
    }
    return self;
}

#pragma mark 重载初始化
-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        [self setupInit];
    }
    return self;
}

#pragma mark 重载初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setupInit];
    }
    return self;
}

#pragma mark 重载初始化
-(instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer{
    if(self = [super initWithFrame:frame textContainer:textContainer]){
        [self setupInit];
    }
    return self;
}

//初始化
-(void)setupInit{
    //设置背景透明
    self.backgroundColor = [UIColor clearColor];
    //添加一个显示提醒文字的Label(显示占位文字的label)
    _placehoderLabel = [[UILabel alloc] init];
    //设置支持多行格式
    _placehoderLabel.numberOfLines = 0;
    //设置清除背景色
    _placehoderLabel.backgroundColor = [UIColor clearColor];
    //设置默认的占位文字的颜色为亮灰色
    _placehoderLabel.textColor = [UIColor lightGrayColor];
    //设置默认的字体为14号字体
    _placehoderLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    //把控件添加到View上
    [self addSubview:_placehoderLabel];
    
    //注册一个通知中心，监听文字的改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(placehoderDidChange)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
    //self.returnKeyType = UIReturnKeyDone;//返回键类型
    //self.keyboardType = UIKeyboardTypeDefault;//键盘类型
    //self.autoresizingMask = UIViewAutoresizingFlexibleHeight;//自适应高度
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;
    self.layer.borderWidth = 0.2;
    self.layer.borderColor = [[UIColor grayColor] CGColor];
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
    _placehoder = placehoder;
    //重新计算文字的Frame
    [self setNeedsLayout];
}

#pragma mark 重载设置文字
-(void)setText:(NSString *)text{
    [super setText:text];
    [self placehoderDidChange];
}
#pragma mark重载计算 Frame
-(void)layoutSubviews{
    [super layoutSubviews];
    //
    if(_placehoder && _placehoder.length > 0){
        CGFloat x = __kESTextView_placehoderX, y = __kESTextView_placehoderY;
        CGFloat maxWith = CGRectGetWidth(self.bounds);
        CGSize placehodlerSize = [_placehoder boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                           options:STR_SIZE_OPTIONS
                                                        attributes:@{NSFontAttributeName : _placehoderLabel.font}
                                                           context:nil].size;
        _placehoderLabel.frame = CGRectMake(x, y, maxWith - x, placehodlerSize.height);
        _placehoderLabel.text = _placehoder;
    }
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
