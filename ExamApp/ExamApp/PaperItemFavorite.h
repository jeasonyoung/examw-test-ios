//
//  PaperItemFavorite.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"

//试题收藏字段定义
#define __k_paperitemfavorite_fields_code @"id"//试题收藏ID
#define __k_paperitemfavorite_fields_subjectCode @"subjectId"//所属科目ID
#define __k_paperitemfavorite_fields_itemCode @"itemId"//所属试题ID
#define __k_paperitemfavorite_fields_itemType @"itemType"//所属试题题型
#define __k_paperitemfavorite_fields_itemContent @"content"//所属试题内容JSON
#define __k_paperitemfavorite_fields_remarks @"remarks"//备注
#define __k_paperitemfavorite_fields_status @"status"//状态
#define __k_paperitemfavorite_fields_createTime @"createTime"//收藏时间
#define __k_paperitemfavorite_fields_sync @"sync"//同步标示
//试题收藏
@interface PaperItemFavorite : NSObject<JSONSerialize>
//试题收藏ID
@property(nonatomic,copy)NSString *code;
//所属科目ID
@property(nonatomic,copy)NSString *subjectCode;
//所属试题ID
@property(nonatomic,copy)NSString *itemCode;
//所属试题题型
@property(nonatomic,assign)NSInteger itemType;
//所属试题内容JSON
@property(nonatomic,copy)NSString *itemContent;
//备注信息
@property(nonatomic,copy)NSString *remarks;
//状态(0-删除，1-收藏)
@property(nonatomic,assign)NSInteger status;
//收藏时间
@property(nonatomic,copy)NSDate *createTime;
//同步标示(0-未同步，1-已同步)
@property(nonatomic,assign)NSInteger sync;
@end
