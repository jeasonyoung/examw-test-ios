//
//  LaunchViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/20.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "LaunchViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface LaunchViewController ()<UIScrollViewDelegate>{
    //切换控制
    UIPageControl *_pageControl;
    //滚动条试图
    UIScrollView *_scrollView;
    //定时器
    NSTimer *_timer;
}
@end

@implementation LaunchViewController

#pragma mark 初始化调用
- (void)viewDidLoad {
    [super viewDidLoad];
    //创建滚动条
    _scrollView = [self createScrollView];
    //图片路径集合
    NSArray *images = [self createImages];
    //添加图片到滚动条view
    [self addImages:images toScrollView:_scrollView];
    //创建分页控制器
    _pageControl = [self createPageControl:images.count];
    //初始化定时器
    _timer = [self createTimer];
}
#pragma mark 初始化图片
-(NSArray *)createImages{
    NSMutableArray *images = [NSMutableArray array];
    for(int i = 0; i < 3; i++){
        NSString *path = [NSString stringWithFormat:@"guide_%d.png",i+1];
        [images addObject:[UIImage imageNamed:path]];
    }
    return images;
}
#pragma mark 创建滚动条
-(UIScrollView *)createScrollView{
    if(_scrollView == nil){
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        _scrollView.backgroundColor = [UIColor whiteColor];//设置滚动条的背景色
        _scrollView.pagingEnabled = YES;//以页为单位滑动，即自动到下一页的开始边界
        _scrollView.showsHorizontalScrollIndicator = NO;//隐藏横向滚动条
        _scrollView.showsVerticalScrollIndicator = NO;//隐藏纵向滚动条
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}
#pragma mark 添加图片到滚动条
-(void)addImages:(NSArray *)images toScrollView:(UIScrollView *)scrollView{
    if(images == nil || images.count == 0 || scrollView == nil) return;
    CGSize size = scrollView.bounds.size;
    CGFloat width = size.width,height = size.height;
    for(int i = 0; i < images.count; i++){
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[images objectAtIndex:i]];
        imageView.frame = CGRectMake(i * width, 0, width, height);
        imageView.contentMode = UIViewContentModeScaleAspectFit;//图片显示时的填充模式
        imageView.backgroundColor = [UIColor clearColor];
        if(i == images.count - 1){//最后一张图片
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake((width - 100)/2, height - 50 * 2.5, 100, 50);//按钮尺寸
            [btn setTitle:@"开始使用" forState:UIControlStateNormal];//设置按钮名称
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
            [imageView addSubview:btn];
            imageView.userInteractionEnabled = YES;//开启时按钮菜响应
        }
        [scrollView addSubview:imageView];
    }
    //设置滚动条内容尺寸
    [scrollView setContentSize:CGSizeMake(width * images.count, height)];
    //设置滚动可见范围
    [scrollView scrollRectToVisible:CGRectMake(0, 0, width, height) animated:YES];
}
#pragma mark 创建页面控制
-(UIPageControl *)createPageControl:(NSUInteger)images{
    if(_pageControl == nil){
        CGSize size = self.view.bounds.size;
        CGFloat width = 78, height = 36;
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((size.width - width)/2, size.height - height - 20, width, height)];
        _pageControl.numberOfPages = images;
       // [_pageControl setBounds:CGRectMake(0, 0, 16 * (images - 1), 16)];//设置pageControl中点的间距为16
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
    //return nil;
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
    if(_pageControl.currentPage == _pageControl.numberOfPages - 1){//最后一页关闭定时器
        [self stopTimer];
    }else{
        rect.origin.x = _pageControl.currentPage * viewSize.width;
        [_scrollView scrollRectToVisible:rect animated:YES];
    }
    NSLog(@"pageControlToNext:%@", sender);
}
#pragma mark 按钮事件处理
-(void)btnClick:(id)sender{
    NSLog(@"btnClick=====");
}
#pragma 内存警告处理
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIScrollViewDelegate

#pragma mark 将开始滚动
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //关闭定时器
    [self stopTimer];
     NSLog(@"WillBeginDragging");
}
#pragma mark 滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"DidScroll");
    CGFloat pageWidth = scrollView.bounds.size.width;
    _pageControl.currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth) + 1;}
#pragma mark 将结束滚动
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //创建定时器
    _timer = [self createTimer];
    NSLog(@"DidEndDragging:%d", decelerate);
}
#pragma mark 滚动结束
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
     NSLog(@"DidEndDecelerating");
}
@end
