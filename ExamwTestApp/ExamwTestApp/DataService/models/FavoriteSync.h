//
//  FavoriteSync.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//收藏数据同步
@interface FavoriteSync : NSObject<JSONSerialize>
//1.收藏ID
@property(nonatomic,copy)NSString *Id;
//2.所属科目ID
@property(nonatomic,copy)NSString *subjectId;
//3.所属试题ID
@property(nonatomic,copy)NSString *itemId;
//4.所属题型
@property(nonatomic,assign)NSInteger itemType;
//5.试题内容JSON
@property(nonatomic,copy)NSString *content;
//6.备注
@property(nonatomic,copy)NSString *remarks;
//7.状态
@property(nonatomic,assign)NSInteger status;
//8.收藏时间
@property(nonatomic,copy)NSDate *createTime;
@end
