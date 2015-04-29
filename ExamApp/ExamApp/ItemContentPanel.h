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
@protocol ItemContentPanelDelegate <NSObject>
@required
//总数
-(NSUInteger)numbersOfItemContentPanel;
//加载数据
-(PaperItem *)dataWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order;
//选中答案
-(void)itemView:(ItemView *)itemView didSelectAtSelected:(ItemViewSelected *)selected atOrder:(NSUInteger)order;
@optional
//加载试题索引
-(NSUInteger)itemIndexWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order;
//加载试题序号
-(NSString *)itemOrderTitleWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order;
//加载答案
-(NSString *)answerWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order atIndex:(NSUInteger)index;
//是否显示答案
-(BOOL)displayAnswerWithItemView:(ItemView *)itemView atOrder:(NSUInteger)order;
@end

//试题内容面板
@interface ItemContentPanel : UIView
//事件代理
@property(nonatomic,assign)id<ItemContentPanelDelegate> delegate;
//重新加载数据
-(void)loadDataAtOrder:(NSUInteger)order;
@end
