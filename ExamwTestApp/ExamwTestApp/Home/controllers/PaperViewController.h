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
-(instancetype)initWithPaperId:(NSString *)paperId andPaperRecordId:(NSString *)recordId;

//静态初始化
+(instancetype)paperWithPaperId:(NSString *)paperId andPaperRecordId:(NSString *)recordId;

@end
