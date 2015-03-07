//
//  ItemAnswersheet.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/6.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//试题答题卡
@interface ItemAnswersheet : UIButton
//所属试卷结构ID
@property(nonatomic,copy)NSString *structureCode;
//所属试题ID
@property(nonatomic,copy)NSString *itemCode;
//所属试题JSON
@property(nonatomic,copy)NSString *itemJSON;
@end
