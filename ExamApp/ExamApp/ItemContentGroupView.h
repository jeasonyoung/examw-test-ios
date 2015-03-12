//
//  ItemContentGroupView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/11.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperReview.h"

//试题内容数据源
@interface ItemContentSource : NSObject
//初始化
-(instancetype)initWithSource:(PaperItem *)source Index:(NSInteger)index Order:(NSInteger)order;
//静态初始化
+(ItemContentSource *)itemContentSource:(PaperItem *)source Index:(NSInteger)index Order:(NSInteger)order;
//数据源
@property(nonatomic,copy,readonly)PaperItem *source;
//索引(共享题)
@property(nonatomic,assign,readonly)NSInteger index;
//排序号
@property(nonatomic,assign,readonly)NSInteger order;
//加载数据
-(void)loadDataWithSource:(PaperItem *)source Index:(NSInteger)index Order:(NSInteger)order;
@end


//试题显示分页集合数据源代理
@protocol ItemContentGroupViewDataSource <NSObject>
//加载试题
-(ItemContentSource *)itemContentAtIndex:(NSInteger)index;
//选中的值
-(void)itemContentWithItemType:(PaperItemType)itemType selectedCode:(NSString *)optCode;
@end


//试题显示分页集合
@interface ItemContentGroupView : UIScrollView
//初始化
-(instancetype)initWithFrame:(CGRect)frame;
//数据源
@property(nonatomic,assign)id<ItemContentGroupViewDataSource> dataSource;
//加载当前试题
-(void)loadContent;
//加载下一题。
-(void)loadNextContent;
//加载上一题
-(void)loadPrevContent;
@end
