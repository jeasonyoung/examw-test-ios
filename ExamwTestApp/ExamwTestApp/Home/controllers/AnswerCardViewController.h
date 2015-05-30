//
//  AnswerCardViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//答题卡试图控制器
@interface AnswerCardViewController : UICollectionViewController
//初始化
-(instancetype)initWithPaperId:(NSString *)paperId andPaperRecordId:(NSString *)recordId;
@end