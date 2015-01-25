//
//  ETImageButton.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeData;
//图片按钮
@interface ETImageButton : UIButton
//图片按钮值
@property(nonatomic,copy)NSString *value;
//按钮文字字体
@property(nonatomic,strong)UIFont *font;
//创建面板
-(void)createPanelWithData:(HomeData *)data;
@end