//
//  ItemContentPanel.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemView.h"


//试题内容面板事件
@protocol ItemContentPanelDelegate <ItemViewDelegate>
@required
//总数
-(NSUInteger)numbersOfItemContentPanel;
//当前
-(NSUInteger)currentOfItemContentPanel;
//前一题
-(void)previousOfItemContentPanel;
//下一题
-(void)nextOfItemContentPanel;
@end

//试题内容面板
@interface ItemContentPanel : UIView
//数据代理
@property(nonatomic,assign)id<ItemViewDataSource> dataSource;
//事件代理
@property(nonatomic,assign)id<ItemContentPanelDelegate> delegate;
//重新加载数据
-(void)loadData;
@end
