//
//  UIViewQueue.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/12.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//视图队列缓存
@interface UIViewQueue : NSObject
//初始化
-(instancetype)initWithCacheCount:(NSInteger)count;
//缓存个数
@property(nonatomic,assign,readonly)NSInteger count;
//入队
-(void)enqueue:(UIView *)view;
//出对
-(UIView *)dequeue;
//清空
-(void)clean;
@end
