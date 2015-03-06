//
//  ItemAnswersheet.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaperReview.h"
//试题答题卡
@interface ItemAnswersheet : UIButton
//所属试题
@property(nonatomic,copy)PaperItem *item;
@end
