//
//  ItemView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaperItem;
@class ItemView;

//试题UI数据源
@protocol ItemViewDataSource <NSObject>
//必须实现
@required
//加载试题数据
-(PaperItem *)dataWithItemView:(ItemView *)itemView;
//可选实现
@optional
//加载试题索引
-(NSUInteger)itemIndexWithItemView:(ItemView *)itemView;
//加载试题序号
-(NSString *)itemOrderTitleWithItemView:(ItemView *)itemView;
//加载答案
-(NSString *)answerWithItemView:(ItemView *)itemView atIndex:(NSUInteger)index;
//是否显示答案
-(BOOL)displayAnswerWithItemView:(ItemView *)itemView;
@end

//试题选中结果
@interface ItemViewSelected : NSObject
//试题ID
@property(nonatomic,copy,readonly)NSString *itemCode;
//试题题型(子题)
@property(nonatomic,assign,readonly)NSUInteger itemType;
//试题索引
@property(nonatomic,assign,readonly)NSUInteger itemIndex;
//选中的代码值
@property(nonatomic,copy,readonly)NSString *selectedCode;
//正确答案
@property(nonatomic,copy,readonly)NSString *rightAnswers;
//试题JSON
@property(nonatomic,copy,readonly)NSString *itemJSON;
//静态初始化
+(instancetype)selectedWithItemCode:(NSString *)itemCode itemType:(NSUInteger)type itemIndex:(NSUInteger)index
                       selectedCode:(NSString *)selectedCode
                       rightAnswers:(NSString *)rightAnswers itemJSON:(NSString *)json;
@end

//试题UI事件代理
@protocol ItemViewDelegate <NSObject>
//选中答案
-(void)itemView:(ItemView *)itemView didSelectAtSelected:(ItemViewSelected *)selected;
@end

//试题UI
@interface ItemView : UIView<UITableViewDataSource,UITableViewDelegate>
//试题ID
@property(nonatomic,copy,readonly)NSString *itemCode;
//试题类型
@property(nonatomic,assign,readonly)NSUInteger itemType;
//数据代理
@property(nonatomic,assign)id<ItemViewDataSource> dataSource;
//事件代理
@property(nonatomic,assign)id<ItemViewDelegate> delegate;
//试题JSON集合
-(NSString *)toItemJSON;
//重新加载数据
-(void)loadData;
//显示答案
-(void)displayAnswer:(BOOL)display;
@end