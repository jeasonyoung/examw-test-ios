//
//  ItemContentGroupView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/11.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemContentGroupView.h"
#import "ItemContentView.h"
#import "UIViewQueue.h"

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
#pragma mark 加载数据
-(void)loadDataWithSource:(PaperItem *)source Index:(NSInteger)index Order:(NSInteger)order{
    _source = source;
    _index = index;
    _order = order;
}
#pragma mark 静态初始化
+(ItemContentSource *)itemContentSource:(PaperItem *)source Index:(NSInteger)index Order:(NSInteger)order{
    return [[ItemContentSource alloc] initWithSource:source Index:index Order:order];
}
@end

#define __k_itemcontentgroupview_queue_max 3//最大队列
//试题显示分页集合成员变量
@interface ItemContentGroupView ()<UIScrollViewDelegate,ItemContentDelegate>{
    NSInteger _pageIndex;
    UIViewQueue *_queue;
}
@end
//试题显示分页集合实现
@implementation ItemContentGroupView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //初始化当前页码
        _pageIndex = 0;
        //试题页面缓存队列
        _queue = [[UIViewQueue alloc] initWithCacheCount:__k_itemcontentgroupview_queue_max];
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
    }
    return self;
}
//加载试题内容视图
-(BOOL)loadItemContentViewAtIndex:(NSInteger)index{
    if(index >= 0 && self.dataSource && [self.dataSource respondsToSelector:@selector(itemContentAtIndex:)]){
        ItemContentSource *source = [self.dataSource itemContentAtIndex:index];
        if(source){
            //计算加载的位置
            CGRect tempFrame = self.frame;
            tempFrame.origin.x = index * CGRectGetWidth(tempFrame);
            tempFrame.origin.y = 0;
            
            ItemContentView *contentView = (ItemContentView *)_queue.dequeue;
            if(!contentView){
                contentView = [[ItemContentView alloc] initWithFrame:tempFrame];
                contentView.itemDelegate = self;
                //NSLog(@"新增:%d",index);
            }else{
                //NSLog(@"从缓存池重复利用:%d",index);
                contentView.frame = tempFrame;
            }
            //加入到队列
            [_queue enqueue:contentView];
            //加载数据
            [contentView loadDataWithItem:source.source Order:source.order Index:source.index];
            //添加到UI
            [self addSubview:contentView];
            return YES;
        }
    }
    return NO;
}
//加载试题可见范围内容
-(void)loadItemContentVisibleAtIndex:(NSInteger)index{
    if(index >= 0){
        //计算加载的位置
        CGRect tempFrame = self.frame;
        tempFrame.origin.x = index * CGRectGetWidth(tempFrame);
        tempFrame.origin.y = 0;
        if(index == 0)index = 1;
        //设置内容尺寸
        self.contentSize = CGSizeMake(CGRectGetWidth(tempFrame) * (index + 1), CGRectGetHeight(tempFrame));
        //设置可见范围
        [self scrollRectToVisible:tempFrame animated:YES];
    }
}

#pragma mark UIScrollViewDelegate
//开始滚动
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"scrollViewDidScroll...%@",NSStringFromCGPoint(scrollView.contentOffset));
    NSInteger index = ceil(scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame));
    //NSLog(@"index===>%d",index);
    if(index < 0)return;
    if(index != _pageIndex){
        //NSLog(@"_pageIndex ===> %d",_pageIndex);
        [self loadItemContentViewAtIndex:index];
        _pageIndex = index;
    }
}
#pragma mark ItemContentDelegate
-(void)optionWithItemType:(PaperItemType)itemType selectedCode:(NSString *)optCode{
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(itemContentWithItemType:selectedCode:)]){
        [self.dataSource itemContentWithItemType:itemType selectedCode:optCode];
    }
}
#pragma mark 加载当前数据
-(void)loadContent{
    [self loadContentAtIndex:_pageIndex];
}
#pragma mark 加载下一题
-(void)loadNextContent{
    _pageIndex++;
    if(![self loadContentAtIndex:_pageIndex]){
        _pageIndex --;
    }
}
#pragma mark 加载上一题
-(void)loadPrevContent{
    _pageIndex--;
    if(![self loadContentAtIndex:_pageIndex]){
        _pageIndex++;
    }
}
//加载试题
-(BOOL)loadContentAtIndex:(NSInteger)index{
    BOOL result = NO;
    if(index >= 0){
        //加载指定位置的数据
        if((result = [self loadItemContentViewAtIndex:index])){
            //翻页到指定位置
            [self loadItemContentVisibleAtIndex:index];
        }
    }
    return result;
}
@end
