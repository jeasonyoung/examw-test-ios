//
//  PaperViewController.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//试卷控制器
@interface PaperViewController : UIViewController
//初始化
-(instancetype)initWithPaperId:(NSString *)paperId andPaperRecordId:(NSString *)recordId andDisplayAnswer:(BOOL)display;
//初始化
-(instancetype)initWithPaperId:(NSString *)paperId andPaperRecordId:(NSString *)recordId;
//加载到指定题序的试题
-(void)loadItemOrder:(NSUInteger)order;
@end
