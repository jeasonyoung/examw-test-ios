//
//  ETHomePanelView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETHomePanelViewDelegate.h"
//主页面板视图(九宫格)
@interface ETHomePanelView : UIView
//主页面板委托
@property(nonatomic,assign)id<ETHomePanelViewDelegate> delegate;
//创建面板
-(void)createPanelWithFrame:(CGRect)frame;
//创建面板
-(void)createPanel;
@end
