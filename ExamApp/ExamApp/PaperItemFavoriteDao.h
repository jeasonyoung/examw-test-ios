//
//  PaperItemFavoriteDao.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
@class PaperItemFavorite;
//试题收藏数据操作
@interface PaperItemFavoriteDao : NSObject
//初始化
-(instancetype)initWithDb:(FMDatabase *)db;
//加载收藏数据
-(PaperItemFavorite *)loadFavorite:(NSString *)favoriteCode;
//根据试题ID加载收藏
-(PaperItemFavorite *)loadFavoriteWithItemCode:(NSString *)itemCode;
//更新收藏数据
-(BOOL)updateFavorite:(PaperItemFavorite **)favorite;
//移除收藏
-(BOOL)removeFavorite:(NSString *)favoriteCode;
//移除收藏
-(BOOL)removeFavoriteWithItemCode:(NSString *)itemCode;
//加载需要同步的收藏
-(NSArray *)loadSyncFavorites;
//更新同步标示
-(void)updateSyncFlagWithIgnoreFavorites:(NSArray *)ignores;
@end
