//
//  ScreenViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ScreenViewController.h"
//屏幕亮度控制器成员变量
@interface ScreenViewController (){
}
@end
//屏幕亮度控制器实现类
@implementation ScreenViewController
#pragma mark 入口函数
- (void)viewDidLoad {
    [super viewDidLoad];
    //隐藏底部Tab菜单栏
    //self.hiddenTabBar = YES;
    //滑动图片
    UIImage *streth = [[UIImage imageNamed:@"slider-bg.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    
    CGFloat width = [self loadVisibleViewFrame].size.width * 0.7;//计算宽度
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, width, 30)];//初始化
    CGPoint center = [self loadVisibleViewCenter];
    center.y -= center.y /2;
    slider.center = center;//设置中点
    slider.backgroundColor = [UIColor clearColor];
    [slider setThumbImage:[UIImage imageNamed:@"slider-knob.png"] forState:UIControlStateNormal];
    [slider setMinimumTrackImage:streth forState:UIControlStateNormal];
    [slider setMaximumTrackImage:streth forState:UIControlStateNormal];
    
    slider.minimumValue = 0.0;//最小值
    slider.maximumValue = 1.0;//最大值
    slider.continuous = YES;//是否连续出发事件处理
    slider.value = [UIScreen mainScreen].brightness;//当前值
    //slider.minimumTrackTintColor = [UIColor greenColor];//最小端颜色
    //slider.maximumTrackTintColor = [UIColor grayColor];//最大端颜色
    //slider.thumbTintColor = [UIColor blackColor];//滑块颜色
   
    //添加值改变事件处理
    [slider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
 
    [self.view addSubview:slider];
}
#pragma mark 滑动值变化事件处理
-(void)sliderChange:(UISlider *)sender{
    [[UIScreen mainScreen] setBrightness:(1.0 - sender.value)];
    NSLog(@"slider-value: %f", (1.0 - sender.value));
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end