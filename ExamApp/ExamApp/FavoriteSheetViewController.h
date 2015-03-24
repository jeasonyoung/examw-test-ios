//
//  FavoriteSheetViewController.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//收藏试题答题卡控制器
@interface FavoriteSheetViewController : UIViewController
//初始化
-(instancetype)initWithSubjectCode:(NSString *)subjectCode andAnswers:(NSMutableDictionary *)answersCache;
@end
