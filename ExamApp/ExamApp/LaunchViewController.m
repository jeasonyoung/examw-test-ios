//
//  LaunchViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "LaunchViewController.h"
//#import "MainViewController.h"
#import "ChoiceProductsViewController.h"

#define __k_launch_total 3//引导页总数
#define __k_launch_margin_bottom 20//底部间距
#define __k_launch_margin_inner 10//控制之间的间距
#define __k_launch_ctrol_width 70//页数控制器宽度
#define __k_launch_ctrol_height 20//页面控制器的高度
#define __k_launch_btn_width 80//按钮宽度
#define __k_launch_btn_height 29//按钮高度
#define __k_launch_btn_border_width 0.4//边框宽度
#define __k_launch_btn_title "开始使用"//按钮标题
#define __k_launch_btn_title_font_size 11.0//字体大小


@interface LaunchViewController ()<UIScrollViewDelegate>{
    //图片链接数组
    NSArray *_imageUrls;
    //滚动条试图
    UIScrollView *_scrollView;
    //切换控制
    UIPageControl *_pageControl;
    //定时器
    NSTimer *_timer;
}
@end

@implementation LaunchViewController

#pragma mark 初始化调用
- (void)viewDidLoad {
    [super viewDidLoad];
    //图片路径集合
    _imageUrls = [self createImageUrls];
    //创建滚动条
    _scrollView = [self createScrollView];
    //创建分页控制器
    _pageControl = [self createPageControlWithSize:_scrollView.bounds.size];
    //初始化定时器
    _timer = [self createTimer];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
#pragma mark 初始化图片
-(NSArray *)createImageUrls{
    NSMutableArray *images = [NSMutableArray array];
    for(int i = 0; i < __k_launch_total; i++){
        [images addObject:[NSString stringWithFormat:@"guide_%d.png",i + 1]];
    }
    return images;
}
#pragma mark 创建滚动条
-(UIScrollView *)createScrollView{
    if(_scrollView == nil){
        CGRect frame = self.view.frame;
        CGFloat width = frame.size.width, height = frame.size.height;
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.backgroundColor = [UIColor whiteColor];//设置滚动条的背景色
        _scrollView.pagingEnabled = YES;//以页为单位滑动，即自动到下一页的开始边界
        _scrollView.showsHorizontalScrollIndicator = NO;//隐藏横向滚动条
        _scrollView.showsVerticalScrollIndicator = NO;//隐藏纵向滚动条
        _scrollView.delegate = self;
        //_scrollView.bounces = NO;//关闭弹簧效果
        for(int i = 0; i < __k_launch_total; i++){
            UIImageView *view = [self createImageViewWithSize:CGSizeMake(width, height) ImageIndex:i];
            [_scrollView addSubview:view];
        }
        [self.view addSubview:_scrollView];
        //设置滚动条内容尺寸
        _scrollView.contentSize = CGSizeMake(width * _imageUrls.count, height);
        //设置滚动可见范围
        [_scrollView scrollRectToVisible:CGRectMake(0, 0, width, height) animated:YES];
        
    }
    return _scrollView;
}
#pragma mark 创建图片UIImageView
-(UIImageView *)createImageViewWithSize:(CGSize)size ImageIndex:(int)index{
    CGFloat width = size.width,height = size.height;
    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[_imageUrls objectAtIndex:index]]];
    imageView.frame = CGRectMake(index * width, 0, width, height);//位置尺寸
    imageView.contentMode = UIViewContentModeScaleAspectFill;//图片显示时的填充模式
    imageView.backgroundColor = [UIColor clearColor];//设置背景透明
    //最后一张图片
    if(index == _imageUrls.count - 1){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, __k_launch_btn_width, __k_launch_btn_height);//按钮尺寸
        btn.center = CGPointMake(width / 2, height - (__k_launch_margin_bottom + __k_launch_ctrol_height + __k_launch_margin_inner + (__k_launch_btn_height / 2)));
        [btn setTitle:@__k_launch_btn_title forState:UIControlStateNormal];//设置按钮名称
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];//设置字体颜色
        btn.titleLabel.font = [UIFont systemFontOfSize:__k_launch_btn_title_font_size];//设置字体大小
        btn.layer.masksToBounds = YES;//启用边框
        btn.layer.borderWidth = __k_launch_btn_border_width;//边框宽度
        btn.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        btn.layer.cornerRadius = 10;//设置圆角
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];//设置按钮事件
        [imageView addSubview:btn];//将按钮添加到视图
        imageView.userInteractionEnabled = YES;//开启事件响应
    }
    return imageView;
}
#pragma mark 创建页面控制
-(UIPageControl *)createPageControlWithSize:(CGSize)size{
    if(_pageControl == nil){
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, __k_launch_ctrol_width, __k_launch_ctrol_height)];
        _pageControl.center = CGPointMake(size.width / 2, size.height - (__k_launch_margin_bottom + (__k_launch_ctrol_height / 2)));
        _pageControl.numberOfPages = _imageUrls.count;//图片总数
        [_pageControl.layer setCornerRadius:8];//设置圆角
        _pageControl.backgroundColor = [UIColor clearColor];//设置背景色
        _pageControl.enabled = YES;
        [_pageControl addTarget:self action:@selector(pageControlToNext:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_pageControl];
    }
    _pageControl.currentPage = 0;//当前页码
    return _pageControl;
}
#pragma mark 创建定时器
-(NSTimer *)createTimer{
    return [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(pageControlToNext:) userInfo:nil repeats:YES];
}
#pragma mark 关闭定时器
-(void)stopTimer{
    if(_timer != nil){
        [_timer invalidate];
    }
}
#pragma mark 页面控制事件处理
-(void)pageControlToNext:(id)sender{
    CGRect rect = _scrollView.frame;
    CGSize viewSize = rect.size;
    int index = (int)_pageControl.currentPage;
    if([sender isKindOfClass:[NSTimer class]]){
        index += 1;
        if(index == _pageControl.numberOfPages - 1){
            [self stopTimer];
        }
    }
    rect.origin.x = index * viewSize.width;
    [_scrollView scrollRectToVisible:rect animated:YES];
    //NSLog(@"pageControlToNext:%@", sender);
}
#pragma mark 按钮事件处理
-(void)btnClick:(id)sender{
    NSLog(@"btnClick===== begin");
    //[[[MainViewController alloc] init] gotoController];
    [[[ChoiceProductsViewController alloc]init]gotoController];
    NSLog(@"btnClick===== end");
}
#pragma 内存警告处理
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIScrollViewDelegate

#pragma mark 将开始滚动
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self stopTimer];//关闭定时器
     NSLog(@"WillBeginDragging");
}
#pragma mark 滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    _pageControl.currentPage = (int)index;
    if(index > _imageUrls.count - 1){
        [self stopTimer];
        [self btnClick:nil];
        NSLog(@"Scroll ===> %f", index);
    }
}
#pragma mark 将结束滚动
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //创建定时器
    _timer = [self createTimer];
    NSLog(@"DidEndDragging:%d", decelerate);
}
@end
