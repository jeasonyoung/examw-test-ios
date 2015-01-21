//
//  NSQueue.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "NSQueue.h"

@interface NSQueue(){
    NSMutableArray *_array;
}
@end
//队列实现
@implementation NSQueue
#pragma mark 初始化
-(id)init{
    if(self = [super init]){
        _array = [NSMutableArray array];
        _count = 0;
    }
    return self;
}
#pragma mark 入队
-(void)enqueue:(id)obj{
    [_array addObject:obj];
    _count = (int)_array.count;
}
#pragma mark 出队
-(id)dequeue{
    id obj =  nil;
    if(_array.count > 0){
        obj = [_array objectAtIndex:0];
        [_array removeObjectAtIndex:0];
        _count = (int)_array.count;
    }
    return obj;
}
#pragma mark 清空队列
-(void)clear{
    [_array removeAllObjects];
    _count = 0;
}
@end