//
//  PaperRecordModel.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//试卷做题记录数据模型
@interface PaperRecordModel : NSObject

//试卷记录ID
@property(nonatomic,copy)NSString *Id;

//所属试卷ID
@property(nonatomic,copy)NSString *paperId;

//做卷状态(Yes-已做完,No-未做完)
@property(nonatomic,assign)BOOL status;

//得分
@property(nonatomic,copy)NSNumber *score;

//做对题数
@property(nonatomic,assign)NSUInteger rights;

//用时(秒)
@property(nonatomic,assign)NSUInteger useTimes;

//初始化
-(instancetype)initWithPaperId:(NSString *)paperId;
@end
