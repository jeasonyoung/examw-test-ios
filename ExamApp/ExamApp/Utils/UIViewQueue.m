//
//  UIViewQueue.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/12.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UIViewQueue.h"
//视图队列缓存成员变量
@interface UIViewQueue (){
    NSMutableArray *_enqueueArrays,*_dequeueArrays;
}
@end
//视图队列缓存实现
@implementation UIViewQueue
#pragma mark 初始化
-(instancetype)initWithCacheCount:(NSInteger)count{
    if(self = [super init]){
        _count = count;
        _enqueueArrays = [NSMutableArray array];
        _dequeueArrays = [NSMutableArray array];
    }
    return self;
}
#pragma mark 入队
-(void)enqueue:(UIView *)view{
    if(view){
        //压入对尾
        [_enqueueArrays addObject:view];
        //检查元素
        if(_enqueueArrays.count > _count){
            //取队首元素
            UIView *view = [_enqueueArrays objectAtIndex:0];
            //移除队首元素
            [_enqueueArrays removeObjectAtIndex:0];
            if(view){
                //从父视图中移除
                [view removeFromSuperview];
                //存入出队队列
                [_dequeueArrays addObject:view];
            }
        }
    }
}
#pragma mark 出对
-(UIView *)dequeue{
    if(_dequeueArrays && _dequeueArrays.count > 0){
        //取出队首元素
        UIView *view = [_dequeueArrays objectAtIndex:0];
        //移除对首元素
        [_dequeueArrays removeObjectAtIndex:0];
        //
        return view;
    }
    return nil;
}
//清空队列
-(void)clean{
    //清空出队队列
    if(_dequeueArrays && _dequeueArrays.count > 0){
        [_dequeueArrays removeAllObjects];
    }
    //清空入队队列
    if(_enqueueArrays && _enqueueArrays.count > 0){
        [_enqueueArrays removeAllObjects];
    }
}
@end
