//
//  PaperItemTitleModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PaperItemModel;
//试题标题数据模型
@interface PaperItemTitleModel : NSObject
//题型
@property(nonatomic,assign)NSUInteger itemType;
//ID
@property(nonatomic,copy)NSString *Id;
//序号
@property(nonatomic,assign)NSUInteger order;
//内容
@property(nonatomic,copy)NSString *content;
//图片键集合
@property(nonatomic,copy)NSArray *images;
//初始化
-(instancetype)initWithItemModel:(PaperItemModel *)itemModel;
@end
