//
//  PaperDetailModel.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define __kPaperDetailModel_typeTitle 1//标题
#define __kPaperDetailModel_typeButtons 2//按钮
#define __kPaperDetailModel_typeDesc 3//描述
//试卷明细数据模型
@interface PaperDetailModel : NSObject
//数据类型
@property(nonatomic,assign)NSUInteger type;
//标题
@property(nonatomic,copy)NSString *title;
//静态初始化
+(instancetype)modelWithType:(NSUInteger)type title:(NSString *)title;
@end
//试卷明细数据模型Frame
@interface PaperDetailModelFrame : NSObject
//模型数据类型
@property(nonatomic,assign,readonly)NSUInteger modelType;
//数据字体
@property(nonatomic,copy,readonly)UIFont *font;
//标题Frame
@property(nonatomic,assign,readonly)CGRect titleFrame;
//标题
@property(nonatomic,copy,readonly)NSString *title;
//标题Attri
@property(nonatomic,copy,readonly)NSAttributedString *titleAttri;
//行高
@property(nonatomic,assign,readonly)CGFloat rowHeight;
//设置数据模型
@property(nonatomic,copy)PaperDetailModel *model;
@end