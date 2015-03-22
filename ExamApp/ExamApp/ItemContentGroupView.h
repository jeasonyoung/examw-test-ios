//
//  ItemContentGroupView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/11.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperReview.h"
#import "ItemContentView.h"

//试题显示分页集合数据源代理
@protocol ItemContentGroupViewDataSource <NSObject>
//加载试题
-(ItemContentSource *)itemContentAtIndex:(NSInteger)index;
//选中的值
-(void)selectedData:(ItemContentSource *)data;
@end


//试题显示分页集合
@interface ItemContentGroupView : UIScrollView
//当前序号
@property(nonatomic,assign,readonly)NSInteger currentOrder;
//是否显示答案
@property(nonatomic,assign)BOOL displayAnswer;
//数据源
@property(nonatomic,assign)id<ItemContentGroupViewDataSource> dataSource;
//初始化
-(instancetype)initWithFrame:(CGRect)frame Order:(NSInteger)order;
//加载当前试题
-(void)loadContent;
//加载试题
-(void)loadContentAtOrder:(NSInteger)order;
//加载下一题。
-(void)loadNextContent;
//加载上一题
-(void)loadPrevContent;
//交卷
-(void)submit;
@end
