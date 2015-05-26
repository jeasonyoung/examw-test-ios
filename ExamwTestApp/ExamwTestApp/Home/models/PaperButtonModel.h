//
//  PaperButtonModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PaperRecordModel;
//试卷按钮数据模型
@interface PaperButtonModel : NSObject

//试卷记录数据模型
@property(nonatomic,copy)PaperRecordModel *recordModel;

//初始化
-(instancetype)initWithPaperRecord:(PaperRecordModel *)recordModel;

@end
