//
//  ItemContentGroupView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/11.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemContentGroupView.h"
#import "ItemContentView.h"
#import "NSQueue.h"
//试题显示数据源
@implementation ItemContentSource
#pragma mark 初始化
-(instancetype)initWithSource:(PaperItem *)source Index:(NSInteger)index Order:(NSInteger)order{
    if(self = [super init]){
        _source = source;
        _index = index;
        _order = order;
    }
    return self;
}
#pragma mark 静态初始化
+(ItemContentSource *)itemContentSource:(PaperItem *)source Index:(NSInteger)index Order:(NSInteger)order{
    return [[ItemContentSource alloc] initWithSource:source Index:index Order:order];
}
@end


//试题显示分页集合成员变量
@interface ItemContentGroupView ()<UIScrollViewDelegate>{
    NSInteger _pageIndex;
    NSQueue *_queue;
}
@end
//试题显示分页集合实现
@implementation ItemContentGroupView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //试题页面缓存队列
        _queue = [[NSQueue alloc] init];
        //以页为单位滑动，即自动到下一页的开始边界
        self.pagingEnabled = YES;
        //隐藏横向滚动条
        self.showsHorizontalScrollIndicator = NO;
        //隐藏纵向滚动条
        self.showsVerticalScrollIndicator = NO;
        //关闭弹簧效果
        //self.bounces = NO;
        //设置委托
        self.delegate = self;
        //设置滚动可见范围
        //[self scrollRectToVisible:frame animated:YES];
    }
    return self;
}
#pragma mark UIScrollViewDelegate
//将开始滚动(加载前后两题)
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"scrollViewWillBeginDragging...%@",NSStringFromCGPoint(scrollView.contentOffset));
//    if(_pageCurrentIndex == _pageIndex == 0){//初始状态
//        NSLog(@"第一次加载...");
//    }else if(_pageCurrentIndex > _pageIndex){//下一页
//        NSLog(@"下一页...");
//    }else if(_pageCurrentIndex < _pageIndex){//上一页
//        NSLog(@"上一页...");
//    }
}
//开始滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidScroll...%@",NSStringFromCGPoint(scrollView.contentOffset));
    CGFloat index = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    if(ceil(index) > floor(index)){//下一页
        NSLog(@"下一页...");
        
    }else if(ceil(index) < floor(index)){//上一页
         NSLog(@"上一页...");
        
    }
    
    
//    int page = ceil(scrollView.contentOffset.x / CGRectGetWidth(self.frame));
//    if(page > _pageIndex){//下一页
//
//    }else{//上一页
//
//    }
//    _pageIndex = page;
}
//将结束滚动
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSLog(@"scrollViewDidEndDragging...%@",NSStringFromCGPoint(scrollView.contentOffset));
}


#pragma mark 加载当前数据
-(void)loadCurrentContent{
    
}
#pragma mark 加载下一题
-(void)loadNextContent{
    
}
#pragma mark 加载上一题
-(void)loadPrevContent{
    
}
@end
