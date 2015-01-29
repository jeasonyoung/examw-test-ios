//
//  ETextView.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//自定义文本输入控件
@interface ETextView : UITextView
//提醒文字
@property(nonatomic,copy)NSString *placehoder;
//提醒文字颜色
@property(nonatomic,strong)UIColor *placehoderColor;
@end
