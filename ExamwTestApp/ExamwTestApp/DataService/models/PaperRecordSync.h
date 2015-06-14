//
//  PaperRecordSync.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerialize.h"
//试卷做题记录上传同步
@interface PaperRecordSync : NSObject<JSONSerialize>
//1.试卷记录Id
@property(nonatomic,copy)NSString *Id;
//2.所属试题Id
@property(nonatomic,copy)NSString *paperId;
//3.状态
@property(nonatomic,assign)NSInteger status;
//4.做对数
@property(nonatomic,assign)NSInteger rights;
//5.共用时(秒)
@property(nonatomic,assign)NSInteger useTimes;
//6.得分
@property(nonatomic,assign)double score;
//7.创建时间
@property(nonatomic,copy)NSDate *createTime;
//8.最后修改时间
@property(nonatomic,copy)NSDate *lastTime;
@end
