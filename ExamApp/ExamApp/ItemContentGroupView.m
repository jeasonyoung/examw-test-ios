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


#define __k_itemcontentgroupview_queue_max 3//最大队列
//试题显示分页集合成员变量
@interface ItemContentGroupView ()<UIScrollViewDelegate,ItemContentDelegate>{
    UIViewQueue *_queue;
    ItemContentView *_currentContentView;
    NSMutableArray *_selectedArrays;
}
@end
//试题显示分页集合实现
@implementation ItemContentGroupView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame Order:(NSInteger)order{
    if(self = [super initWithFrame:frame]){
        //是否显示答案
        _displayAnswer = NO;
        //初始化当前页码
        _currentOrder = order;
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
//初始化
-(instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame Order:0];
}
//加载试题内容视图
-(BOOL)loadItemContentViewAtOrder:(NSInteger)order{
    if(index >= 0 && self.dataSource && [self.dataSource respondsToSelector:@selector(itemContentAtOrder:)]){
        ItemContentSource *source = [self.dataSource itemContentAtOrder:order];
        if(source){
            //计算加载的位置
            CGRect tempFrame = self.frame;
            tempFrame.origin.x = order * CGRectGetWidth(tempFrame);
            tempFrame.origin.y = 0;
            
            _currentContentView = (ItemContentView *)_queue.dequeue;
            if(!_currentContentView){
                _currentContentView = [[ItemContentView alloc] initWithFrame:tempFrame];
                _currentContentView.itemDelegate = self;
                //NSLog(@"新增:%d",(int)order);
            }else{
                //NSLog(@"从缓存池重复利用:%d",order);
                _currentContentView.frame = tempFrame;
            }
            //加入到队列
            [_queue enqueue:_currentContentView];
            //加载数据
            [_currentContentView loadDataWithSource:source andDisplayAnswer:_displayAnswer];
            
            //
            //NSLog(@"子控件1: %@",self.subviews);
            if(self.subviews && self.subviews.count > 0){
                for(UIView *subView in self.subviews){
                    if(subView && CGRectEqualToRect(subView.frame, tempFrame)){//去除缓存时位置叠加
                        [subView removeFromSuperview];
                    }
                }
            }
            //NSLog(@"子控件2: %@",self.subviews);
            //添加到UI
            [self addSubview:_currentContentView];
            return YES;
        }
    }
    return NO;
}
//加载试题可见范围内容
-(void)loadItemContentVisibleAtOrder:(NSInteger)order{
    if(index >= 0){
        //计算加载的位置
        CGRect tempFrame = self.frame;
        tempFrame.origin.x = order * CGRectGetWidth(tempFrame);
        tempFrame.origin.y = 0;
        if(order <= 0)order = 1;
        //设置内容尺寸
        self.contentSize = CGSizeMake(CGRectGetWidth(tempFrame) * (order + 1), CGRectGetHeight(tempFrame));
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
    if(index != _currentOrder){
        //NSLog(@"_pageIndex ===> %d",_pageIndex);
        [self loadItemContentViewAtOrder:index];
        _currentOrder = index;
    }
}
#pragma mark ItemContentDelegate
-(void)selectedOption:(ItemContentSource *)source{
    if(!source || !source.source) return;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(selectedData:)]){
        PaperItemType itemType = (PaperItemType)source.source.type;
        if(itemType != PaperItemTypeMulty && itemType != PaperItemTypeUncertain){
            [self.dataSource selectedData:source];
            return;
        }
        //多选
        if(!_selectedArrays) _selectedArrays = [NSMutableArray array];
        if(![_selectedArrays containsObject:source]){
            [_selectedArrays addObject:source];
        }
    }
}
-(void)selectMultyOptionHandler{
    if(!_selectedArrays ||  _selectedArrays.count == 0)return;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(selectedData:)]){
        NSMutableString *selectedValues = [NSMutableString string];
        ItemContentSource *source;
        for(NSInteger i = 0; i < _selectedArrays.count; i++){
            source = [_selectedArrays objectAtIndex:i];
            if(source && source.value && source.value.length > 0){
                if(selectedValues.length > 0)[selectedValues appendString:@","];
                [selectedValues appendFormat:@"%@",source.value];
            }
        }
        //
        [_selectedArrays removeAllObjects];
        //
        if(source && selectedValues.length > 0){
            source.value = [selectedValues copy];
            [self.dataSource selectedData:source];
            selectedValues = nil;
        }
    }
}
#pragma mark 加载当前数据
-(void)loadContent{
    [self loadContentAtOrder:_currentOrder];
}
#pragma mark 加载数据
-(void)loadContentAtOrder:(NSInteger)order{
    [self loadContentDataAtOrder:order];
}
#pragma mark 加载下一题
-(void)loadNextContent{
    [self selectMultyOptionHandler];
    _currentOrder++;
    if(![self loadContentDataAtOrder:_currentOrder]){
        _currentOrder--;
    }
}
#pragma mark 加载上一题
-(void)loadPrevContent{
    [self selectMultyOptionHandler];
    _currentOrder--;
    if(![self loadContentDataAtOrder:_currentOrder]){
        _currentOrder++;
    }
}
#pragma mark 交卷
-(void)submit{
    [self selectMultyOptionHandler];
}
//加载试题
-(BOOL)loadContentDataAtOrder:(NSInteger)order{
    BOOL result = NO;
    if(index >= 0){
        //加载指定位置的数据
        if((result = [self loadItemContentViewAtOrder:order])){
            //翻页到指定位置
            [self loadItemContentVisibleAtOrder:order];
        }
    }
    return result;
}
#pragma mark 是否显示答案
-(void)showDisplayAnswer:(BOOL)displayAnswer{
    if(_currentContentView){
        [_currentContentView showDisplayAnswer:displayAnswer];
    }
}
@end
