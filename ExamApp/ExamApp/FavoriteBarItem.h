//
//  FavoriteButton.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FavoriteBarItem;
//收藏按钮对象委托
@protocol FavoriteBarItemDelegate <NSObject>
@required
//收藏状态加载
-(BOOL)stateWithFavorite:(FavoriteBarItem*)favorite;
//收藏点击事件
-(void)clickWithFavorite:(FavoriteBarItem*)favorite;
@end
//收藏按钮
@interface FavoriteBarItem : UIBarButtonItem
//设置委托
@property(nonatomic,assign)id<FavoriteBarItemDelegate> delegate;
//状态
@property(nonatomic,assign)BOOL state;
//初始化
-(instancetype)initWidthDelegate:(id<FavoriteBarItemDelegate>)delegate;
//重新加载数据
-(void)reloadData;
@end