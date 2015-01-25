//
//  ETUserView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/24.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ETUserViewDelegate;
//用户信息面板
@interface ETUserView : UIView
//用户信息面板数据源
@property(nonatomic,assign)id<ETUserViewDelegate> delegate;
//创建面板
-(void)createPanelWithFrame:(CGRect)frame;
//创建面板
-(void)createPanel;
@end