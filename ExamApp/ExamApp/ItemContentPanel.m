//
//  ItemContentPanel.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ItemContentPanel.h"

#define __kItemContentPanel_max 3//
//试题内容面板成员变量
@interface ItemContentPanel ()<UIScrollViewDelegate>{
    UIScrollView *_contentView;
    NSInteger _total,_pageIndex;
    CGFloat _pageWidth,_pageHeight;
    NSMutableArray *_panelArrays;
    BOOL _isScroll;
}
@end

//试题内容面板实现
@implementation ItemContentPanel
#pragma mark 重载初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //初始化容器
        _contentView = [[UIScrollView alloc]init];
        _contentView.contentMode = UIViewContentModeCenter;
        //初始化视图数组
        _panelArrays = [NSMutableArray arrayWithCapacity:__kItemContentPanel_max];
        //以页为单位滑动，即自动到下一页的开始边界
        _contentView.pagingEnabled = YES;
        //隐藏横向滚动条
        _contentView.showsHorizontalScrollIndicator = NO;
        //隐藏纵向滚动条
        _contentView.showsVerticalScrollIndicator = NO;
        //关闭弹簧效果
        _contentView.bounces = NO;
        //设置委托
        _contentView.delegate = self;
        //添加到主界面
        [self addSubview:_contentView];
        //初始化面板Frame
        [self setupInitViewsFrames];
    }
    return self;
}
//添加初始化面板Frame
-(void)setupInitViewsFrames{
    CGSize scrollViewSize = self.bounds.size;
    _pageWidth = scrollViewSize.width;
    _pageHeight = scrollViewSize.height;
    _contentView.frame = CGRectMake(0, 0, _pageWidth, _pageHeight);
    _contentView.contentSize = CGSizeMake(_pageWidth *_total, _pageHeight);
    
    for(NSUInteger i = 0; i < __kItemContentPanel_max; i++){
        CGRect tempFrame = CGRectMake(_pageWidth * i, 0, _pageWidth, _pageHeight);
        
        ItemView *itemPanel = [[ItemView alloc]initWithFrame:tempFrame];
        [_contentView addSubview:itemPanel];
        [_panelArrays addObject:itemPanel];
    }
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x,offset = 0;
    if(offsetX > _pageWidth * _pageIndex){
        offset = _pageWidth * 0.9;
    }else{
        offset = _pageWidth * 0.1;
    }
    CGFloat index = ((offsetX + offset)/ _pageWidth);
    NSInteger page = index;
    NSLog(@"scrollViewDidScroll => %d ----- 0", (int)page);
    if(!_isScroll && page != _pageIndex && self.delegate){
        _isScroll = YES;
        NSLog(@"scrollViewDidScroll => %d ----- 1", (int)page);
        if(page > _pageIndex){//下一个
            if([self.delegate respondsToSelector:@selector(nextOfItemContentPanel)]){
                [self.delegate nextOfItemContentPanel];
            }
        }else{//上一个
            if([self.delegate respondsToSelector:@selector(previousOfItemContentPanel)]){
                [self.delegate previousOfItemContentPanel];
            }
        }
        [self loadPanelItemData];
        _isScroll = NO;
    }
}
//加载数据
-(void)loadPanelItemData{
    //当前数据页码
    _pageIndex = [self loadCurrentPageIndex];
    if(_pageIndex < 0 || _pageIndex > _total -1) return;
    //View索引
    NSUInteger row = _pageIndex % _panelArrays.count;
    NSLog(@"_panelArrays-index:%d",row);
    //加载ItemPanel
    ItemView *itemPanel = [_panelArrays objectAtIndex:row];
    if(itemPanel){
        itemPanel.dataSource = _dataSource;
        itemPanel.delegate = _delegate;
        //
        CGRect tempFrame = itemPanel.frame;
        tempFrame.origin.x = _pageIndex * _pageWidth;
        itemPanel.frame = tempFrame;
        //加载数据
        [itemPanel loadData];
    }
}

#pragma mark 加载数据
-(void)loadData{
    //获取数据总条数
    if(self.delegate && [self.delegate respondsToSelector:@selector(numbersOfItemContentPanel)]){
        _total = [self.delegate numbersOfItemContentPanel];
    }
    //重置滚动范围
    _contentView.contentSize = CGSizeMake(_pageWidth *_total, _pageHeight);
    //加载Panel数据
    [self loadPanelItemData];
    //设置可视范围
    CGPoint p = CGPointZero;
    p.x = _pageWidth * _pageIndex;
    //设置可视范围
    [_contentView setContentOffset:p animated:NO];    
}
//获取当前页码索引
-(NSUInteger)loadCurrentPageIndex{
    NSUInteger current = 0;
    if(self.delegate  && [self.delegate respondsToSelector:@selector(currentOfItemContentPanel)]){
        current = [self.delegate currentOfItemContentPanel];
    }
    return current;
}
@end
