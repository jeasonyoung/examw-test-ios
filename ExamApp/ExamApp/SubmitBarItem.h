//
//  SubmitBarItem.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SubmitBarItem;
//交卷按钮委托
@protocol SubmitBarItemDelegate <NSObject>
@required
//交卷按钮点击确认事件
-(void)clickSubmitBar:(SubmitBarItem *)bar;
@end
//交卷按钮
@interface SubmitBarItem : UIBarButtonItem
//设置事件委托
@property(nonatomic,assign)id<SubmitBarItemDelegate> delegate;
//初始化
-(instancetype)initWithDelegate:(id<SubmitBarItemDelegate>)delegate;
@end
