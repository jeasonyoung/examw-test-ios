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

#import "AppClientSettings.h"

#define __kAboutViewController_marginTop 25//顶部间距
#define __kAboutViewController_marginMax 15//内部间距
#define __kAboutViewController_marginMin 2//相邻的间距

#define __kAboutViewController_titleTel @"客服热线:4000-525-585"//
#define __kAboutViewController_titleCopyright @"版权所有 © 2006-%@ 中华考试网(Examw.com)"//
#define __kAboutViewController_titleCopyrightFontSize 11.0//版权信息字体大小

#define __kAboutViewController_icon @"AppIcon60x60@3x.png"//

#define __kAboutViewController_dateFormat @"yyyy"

//关于应用控制器成员变量
@interface AboutViewController (){
    
}
@end
//关于应用控制器实现类
@implementation AboutViewController
#pragma mark 入口函数
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化设置
    AppClientSettings *settings = [AppClientSettings clientSettings];
    //
    NSNumber *ty = [NSNumber numberWithFloat:([self loadTopHeight] + __kAboutViewController_marginTop)];
    //设置图标
    [self setupIconWithOutY:&ty];
    //设置软件名称
    ty = [NSNumber numberWithFloat:(ty.floatValue + __kAboutViewController_marginMax)];
    [self setupTitle:settings.appClientName OutY:&ty labelBlock:^(UILabel *label) {
        label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];;
    }];
    //设置产品名称
    //设置字体
    UIFont *font = [UIFont systemFontOfSize:__kAboutViewController_titleCopyrightFontSize];
    ty = [NSNumber numberWithFloat:(ty.floatValue + __kAboutViewController_marginMin)];
    [self setupTitle:settings.appClientProductName OutY:&ty labelBlock:^(UILabel *label) {
        label.font = font;
    }];
    //获取屏幕y中点
    CGFloat my = CGRectGetMidY(self.view.frame);
    if(ty.floatValue < my){
        ty = [NSNumber numberWithFloat:(my * 1.5 + __kAboutViewController_marginMax)];
    }else{
        ty = [NSNumber numberWithFloat:(ty.floatValue +__kAboutViewController_marginMax)];
    }
    //设置客服热线
    [self setupTitle:__kAboutViewController_titleTel OutY:&ty labelBlock:^(UILabel *label) {
        label.font = font;
    }];
    //设置版本信息
    ty = [NSNumber numberWithFloat:(ty.floatValue + __kAboutViewController_marginMin)];
    NSString *copyright = [NSString stringWithFormat:__kAboutViewController_titleCopyright,
                           [NSString stringFromDate:[NSDate date] withDateFormat:__kAboutViewController_dateFormat]];
    [self setupTitle:copyright OutY:&ty labelBlock:^(UILabel *label) {
        label.font = font;
        label.textColor = [UIColor darkTextColor];
    }];
}
//设置图标
-(void)setupIconWithOutY:(NSNumber **)ty{
    //设置图标图片
    NSString *iconName = __kAboutViewController_icon;
    //判断图标是否存在
    if(iconName && iconName.length > 0){
        //加载图标图片
        UIImage *iconImage = [UIImage imageNamed:iconName];
        //获取图标尺寸
        CGSize iconSize = iconImage.size;
        //将图标装载到视图
        UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
        //设置视图尺寸
        iconView.frame = CGRectMake(0, 0, iconSize.width, iconSize.height);
        //设置内容模式
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        //设置居中
        iconView.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, (*ty).floatValue + (iconSize.height/2));
        //添加到容器
        [self.view addSubview:iconView];
        //输出y坐标
        *ty = [NSNumber numberWithFloat:CGRectGetMaxY(iconView.frame)];
    }
}
//设置内容
-(void)setupTitle:(NSString *)title OutY:(NSNumber **)ty labelBlock:(void(^)(UILabel *label))block{
    if(title && title.length > 0){
        //初始化
        UILabel *lbContent = [[UILabel alloc]init];
        //设置字体居中
        lbContent.textAlignment = NSTextAlignmentCenter;
        //设置多行
        lbContent.numberOfLines = 0;
        //属性设置
        if(block){
            block(lbContent);
        }
        //获取宽度
        CGFloat width = CGRectGetWidth(self.view.frame);
        //内容尺寸
        CGSize titleSize = [title sizeWithFont:lbContent.font
                             constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        //设置尺寸
        lbContent.frame = CGRectMake(0, (*ty).floatValue, width, titleSize.height);
        //设置内容
        lbContent.text = title;
        //添加到容器
        [self.view addSubview:lbContent];
        //输出y坐标
        *ty = [NSNumber numberWithFloat:CGRectGetMaxY(lbContent.frame)];
    }
}

#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
