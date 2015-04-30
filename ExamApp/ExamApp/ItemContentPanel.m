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
@interface ItemContentPanel ()<UIScrollViewDelegate,ItemViewDataSource,ItemViewDelegate>{
    UIScrollView *_contentView;
    NSInteger _total,_pageIndex;
    CGFloat _pageWidth,_pageHeight;
    NSMutableArray *_panelArrays;
    BOOL _isLoading;
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
        itemPanel.dataSource = self;
        itemPanel.delegate = self;
        [_contentView addSubview:itemPanel];
        [_panelArrays addObject:itemPanel];
    }
}

#pragma mark UIScrollViewDelegate
//滚动中
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //如果正在加载数据则忽略滚动
    if(_isLoading)return;
    //计算滚动边界偏移量
    CGFloat offsetX = scrollView.contentOffset.x,offset = 0;
    if(offsetX > _pageWidth * _pageIndex){
        offset = _pageWidth * 0.9;
    }else{
        offset = _pageWidth * 0.1;
    }
    NSInteger index = ((offsetX + offset)/ _pageWidth);
    //NSLog(@"scrollViewDidScroll => %d ----- 0", (int)index);
    if(index >= 0 && index < _total && index != _pageIndex){
        //NSLog(@"scrollViewDidScroll => %d ----- 1", (int)index);
        //开始加载数据
        _isLoading = YES;
        //当前页码赋值
        _pageIndex = index;
        //加载数据
        NSLog(@"2--------%s",__func__);
        [self loadPanelItemDataWithPageIndex:_pageIndex];
    }
}
//加载数据
-(void)loadPanelItemDataWithPageIndex:(NSUInteger)index {
    //View索引
    NSUInteger row = _pageIndex % _panelArrays.count;
    NSLog(@"_panelArrays-index:%d",(int)row);
    //加载ItemPanel
    ItemView *itemPanel = [_panelArrays objectAtIndex:row];
    if(itemPanel){
        //开启等待动画
        [itemPanel showWait];
        
        CGRect tempFrame = itemPanel.frame;
        tempFrame.origin.x = _pageIndex * _pageWidth;
        itemPanel.frame = tempFrame;
        //加载数据
        NSLog(@"4--------%s",__func__);
        [itemPanel loadData];
        NSLog(@"5--------%s",__func__);
        
        //关闭等待动画
        [itemPanel hideWait];
        
        //数据加载完毕
        _isLoading = NO;
    }
}
#pragma mark 加载数据
-(void)loadDataAtOrder:(NSUInteger)order{
    //获取数据总条数
    if(self.delegate && [self.delegate respondsToSelector:@selector(numbersOfItemContentPanel)]){
        _total = [self.delegate numbersOfItemContentPanel];
    }
    if(_total <= 0)return;
    //设置当前序号
    if(order > _total){
        _pageIndex = _total - 1;
    }else{
        _pageIndex = order;
    }
    //重置滚动范围
    _contentView.contentSize = CGSizeMake(_pageWidth *_total, _pageHeight);
    //加载Panel数据
    [self loadPanelItemDataWithPageIndex:_pageIndex];
    //设置可视范围
    CGPoint p = CGPointZero;
    p.x = _pageWidth * _pageIndex;
    //设置可视范围
    [_contentView setContentOffset:p animated:NO];
}

#pragma mark ItemViewDataSource
//加载数据
-(PaperItem *)dataWithItemView:(ItemView *)itemView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(dataWithItemView:atOrder:)]){
        return [self.delegate dataWithItemView:itemView atOrder:_pageIndex];
    }
    return nil;
}
//加载试题索引
-(NSUInteger)itemIndexWithItemView:(ItemView *)itemView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(itemIndexWithItemView:atOrder:)]){
        return [self.delegate itemIndexWithItemView:itemView atOrder:_pageIndex];
    }
    return 0;
}
//加载试题序号
-(NSString *)itemOrderTitleWithItemView:(ItemView *)itemView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(itemOrderTitleWithItemView:atOrder:)]){
        return [self.delegate itemOrderTitleWithItemView:itemView atOrder:_pageIndex];
    }
    return [NSString stringWithFormat:@"%d",(int)(_pageIndex + 1)];
}
//加载答案
-(NSString *)answerWithItemView:(ItemView *)itemView atIndex:(NSUInteger)index{
    if(self.delegate && [self.delegate respondsToSelector:@selector(answerWithItemView:atOrder:atIndex:)]){
        return [self.delegate answerWithItemView:itemView atOrder:_pageIndex atIndex:index];
    }
    return nil;
}
//是否显示答案
-(BOOL)displayAnswerWithItemView:(ItemView *)itemView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(displayAnswerWithItemView:atOrder:)]){
        return [self.delegate displayAnswerWithItemView:itemView atOrder:_pageIndex];
    }
    return NO;
}
#pragma mark ItemViewDelegate
//选中
-(void)itemView:(ItemView *)itemView didSelectAtSelected:(ItemViewSelected *)selected{
    if(self.delegate && [self.delegate respondsToSelector:@selector(itemView:didSelectAtSelected:atOrder:)]){
        [self.delegate itemView:itemView didSelectAtSelected:selected atOrder:_pageIndex];
    }
}
#pragma mark 内存释放
-(void)dealloc{
    if(_contentView){
        _contentView.delegate = nil;
    }
}
@end
