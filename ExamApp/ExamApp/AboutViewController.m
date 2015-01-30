//
//  AboutViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AboutViewController.h"
#import "UIViewController+VisibleView.h"
#import "NSDate+TimeZone.h"
#import "NSString+Date.h"
#import "NSString+Size.h"

#import "AboutData.h"

#define __k_about_margin_top 25//顶部间距
#define __k_about_margin_bottom 20//底部间距
#define __k_about_margin_inner_max 15//内部间距
#define __k_about_margin_inner_min 2//相邻的间距
#define __k_about_title_width_per 0.4//标题所占宽度的比例
#define __k_about_title_font_size 13.0//标题字体大小
#define __k_about_title_ver "版本："//
#define __k_about_title_website "官网："//
#define __k_about_title_tel "客服热线："//
#define __k_about_copyright "版权所有 © 2006-%@ %@"//
#define __k_about_copyright_font_size 11.0//版权信息字体大小

//关于应用控制器成员变量
@interface AboutViewController (){
    AboutData *_data;
}
@end
//关于应用控制器实现类
@implementation AboutViewController
#pragma mark 入口函数
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载数据
    _data = [AboutData loadAboutData];
    //
    CGRect tempFrame = self.view.frame;
    CGFloat x = tempFrame.size.width / 2, y = [self loadTopHeight] + __k_about_margin_top;
    //图标
    y = [self createIconWithX:x Y:y];
    //标题
    UIColor *titleFontColor = [UIColor blackColor];
    y = [self createTitleWithFontColor:titleFontColor X:x Y:y];
    //子标题
    y = [self createSubTitleWithFontColor:titleFontColor X:x Y:y];
    //详细信息
    y = [self createDetailWithWidth:tempFrame.size.width Y:y];
    y += __k_about_margin_inner_max;
    //版权信息
    [self createCopyRightWithSize:tempFrame.size X:x Y:y];
}
#pragma mark 创建图标
-(CGFloat)createIconWithX:(CGFloat)x
                        Y:(CGFloat)y{
    if(_data.icon != nil && _data.icon.length > 0){
        UIImage *iconImage = [UIImage imageNamed:_data.icon];
        CGSize iconSize = iconImage.size;
        UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
        iconView.frame = CGRectMake(0, 0, iconSize.width, iconSize.height);
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.center = CGPointMake(x, y + (iconSize.height / 2));
        [self.view addSubview:iconView];
        y += iconView.bounds.size.height;
    }
    return y;
}
#pragma mark 创建标题
-(CGFloat)createTitleWithFontColor:(UIColor *)fontColor
                                 X:(CGFloat)x
                                 Y:(CGFloat)y{
    if(_data.title != nil && _data.title.length > 0){
        y += __k_about_margin_inner_max;
        UIFont *titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        CGSize titleSize = [_data.title sizeWithFont:titleFont];
        UILabel *lbTitle =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleSize.width, titleSize.height)];
        lbTitle.font = titleFont;
        lbTitle.text = _data.title;
        lbTitle.textColor = fontColor;
        lbTitle.textAlignment = NSTextAlignmentCenter;
        lbTitle.center = CGPointMake(x, y + (titleSize.height / 2));
        [self.view addSubview:lbTitle];
        y += lbTitle.bounds.size.height;
    }
    return y;
}
#pragma mark 创建子标题
-(CGFloat)createSubTitleWithFontColor:(UIColor *)fontColor
                                    X:(CGFloat)x
                                    Y:(CGFloat)y{
    if(_data.subTitle != nil && _data.subTitle.length > 0){
        y += __k_about_margin_inner_min;
        UIFont *subTitleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        CGSize subTitleSize = [_data.subTitle sizeWithFont:subTitleFont];
        UILabel *lbSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, subTitleSize.width, subTitleSize.height)];
        lbSubTitle.font = subTitleFont;
        lbSubTitle.text = _data.subTitle;
        lbSubTitle.textColor = fontColor;
        lbSubTitle.textAlignment = NSTextAlignmentCenter;
        lbSubTitle.center = CGPointMake(x, y + (subTitleSize.height / 2));
        [self.view addSubview:lbSubTitle];
        y += lbSubTitle.bounds.size.height;
    }
    return y;
}
#pragma mark 创建详细信息
-(CGFloat)createDetailWithWidth:(CGFloat)width
                              Y:(CGFloat)y{
    y += __k_about_margin_inner_max;
    UIFont *font = [UIFont systemFontOfSize:__k_about_title_font_size];
    //版本
    y = [self createDetailWithFont:font Title:@__k_about_title_ver Value:[_data.version stringValue] Width:width Y:y];
    y += __k_about_margin_inner_min;
    //官网
    y = [self createDetailWithFont:font Title:@__k_about_title_website Value:_data.website Width:width Y:y];
    y += __k_about_margin_inner_min;
    //客服热线
    y = [self createDetailWithFont:font Title:@__k_about_title_tel Value:_data.title Width:width Y:y];
    
    return y;
}
//创建详细信息
-(CGFloat)createDetailWithFont:(UIFont *)font
                         Title:(NSString *)title
                         Value:(NSString *)value
                          Width:(CGFloat)width
                             Y:(CGFloat)y{
    if(title != nil && title.length > 0){
        //标题
        CGSize titleSize = [title sizeWithFont:font];
        UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake((width * __k_about_title_width_per) - titleSize.width , y, titleSize.width, titleSize.height)];
        lbTitle.font = font;
        lbTitle.text = title;
        lbTitle.textColor = [UIColor darkGrayColor];
        lbTitle.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:lbTitle];
        //内容
        if(value != nil && value.length > 0){
            CGSize valueSize = [value sizeWithFont:font];
            UILabel *lbValue = [[UILabel alloc] initWithFrame:CGRectMake(width * __k_about_title_width_per, y, valueSize.width, valueSize.height)];
            lbValue.font = font;
            lbValue.text = value;
            lbValue.textColor = [UIColor blueColor];
            lbValue.textAlignment = NSTextAlignmentLeft;
            [self.view addSubview:lbValue];
        }
        y += titleSize.height;
    }
    return y;
}
#pragma mark 创建版权信息
-(void)createCopyRightWithSize:(CGSize)size
                               X:(CGFloat)x
                               Y:(CGFloat)y{
    
    NSString *year = [NSString stringFromDate:[[NSDate date] localTime] withDateFormat:@"yyyy"];
    NSString *copyright = [NSString stringWithFormat:@__k_about_copyright,year,_data.copyright];
    UIFont *font = [UIFont systemFontOfSize:__k_about_copyright_font_size];
    CGSize copyrightSize = [copyright sizeWithFont:font];
    CGRect tempFrame = CGRectMake(x, y, size.width, copyrightSize.height);
    if(size.height - y > (copyrightSize.height + __k_about_margin_bottom)){
        tempFrame.origin.y = size.height - __k_about_margin_bottom - copyrightSize.height;
    }
    UILabel *lbCopyright = [[UILabel alloc] initWithFrame:tempFrame];
    lbCopyright.center = CGPointMake(x, tempFrame.origin.y + copyrightSize.height/2);
    lbCopyright.font = font;
    lbCopyright.text = copyright;
    lbCopyright.textColor = [UIColor darkGrayColor];
    lbCopyright.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lbCopyright];
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
