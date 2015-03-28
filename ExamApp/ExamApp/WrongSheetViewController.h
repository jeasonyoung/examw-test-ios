//
//  WrongSheetViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//错题重做答题卡视图
@interface WrongSheetViewController : UIViewController
//初始化
-(instancetype)initWithSubjectCode:(NSString *)subjectCode andAnswers:(NSMutableDictionary *)answersCache;
@end
