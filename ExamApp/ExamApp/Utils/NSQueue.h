//
//  NSQueue.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//队列
@interface NSQueue : NSObject
//队列元素
@property(nonatomic,readonly)int count;
//入队
-(void)enqueue:(id)obj;
//出队
-(id)dequeue;
//清空队列
-(void)clear;
@end