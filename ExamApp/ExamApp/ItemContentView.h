//
//  ItemTestView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/7.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperReview.h"

//试题内容数据源
@interface ItemContentSource : NSObject
@property(nonatomic,copy,readonly)NSString *structureCode;
//数据源
@property(nonatomic,copy,readonly)PaperItem *source;
//索引(共享题)
@property(nonatomic,assign,readonly)NSInteger index;
//排序号
@property(nonatomic,assign,readonly)NSInteger order;
//选中的值
@property(nonatomic,copy)NSString *value;
//加载数据
-(void)loadDataWithStructureCode:(NSString *)code
                          Source:(PaperItem *)source
                           Index:(NSInteger)index
                           Order:(NSInteger)order
                   SelectedValue:(NSString *)value;
//静态初始化
+(instancetype)itemContentStructureCode:(NSString *)code
                                 Source:(PaperItem *)source
                                  Index:(NSInteger)index
                                  Order:(NSInteger)order
                          SelectedValue:(NSString *)value;
@end

//考试试题视图委托
@protocol ItemContentDelegate <NSObject>
//选项选中事件
-(void)selectedOption:(ItemContentSource *)source;
@end

//考试试题视图
@interface ItemContentView : UIScrollView
//初始化
-(instancetype)initWithFrame:(CGRect)frame;
//试题委托
@property(nonatomic,assign)id<ItemContentDelegate> itemDelegate;
//加载数据
//-(void)loadDataWithSource:(ItemContentSource *)source;
//加载数据并显示答案
-(void)loadDataWithSource:(ItemContentSource *)source andDisplayAnswer:(BOOL)displayAnswer;
@end

