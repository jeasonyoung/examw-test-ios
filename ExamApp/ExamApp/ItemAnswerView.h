//
//  ItemAnswerView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/3/16.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

//答案及其解析的数据源
@interface ItemAnswerViewSource : NSObject
//我的答案
@property(nonatomic,copy,readonly)NSString *myAnswer;
//正确答案
@property(nonatomic,copy,readonly)NSString *rightAnswer;
//答案解析
@property(nonatomic,copy,readonly)NSString *analysis;
//加载数据
-(void)loadMyAnswer:(NSString *)myAnswer RightAnswer:(NSString *)rightAnswer Analysis:(NSString *)analysis;
//静态初始化
+(instancetype)itemAnswer:(NSString *)myAnswer RightAnswer:(NSString *)rightAnswer Analysis:(NSString *)analysis;
@end

//试题答案及其解析
@interface ItemAnswerView : UIView
//初始化
-(instancetype)initWithFrame:(CGRect)frame;
//加载数据
-(void)loadData:(ItemAnswerViewSource *)data;
//清空数据
-(void)clean;
@end
