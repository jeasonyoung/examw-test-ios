//
//  PaperInfoModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/24.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//试卷信息数据模型
@interface PaperInfoModel : NSObject

//试卷ID
@property(nonatomic,copy)NSString *Id;

//试卷名称
@property(nonatomic,copy)NSString *name;

//所属科目
@property(nonatomic,copy)NSString *subject;

//试题总数
@property(nonatomic,assign)NSUInteger total;

//创建时间
@property(nonatomic,copy)NSString *createTime;

@end
