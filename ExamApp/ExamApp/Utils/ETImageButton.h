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
@property(nonatomic,copy,readonly)NSString *value;
//图片按钮名称
@property(nonatomic,copy,readonly)NSString *title;
//创建面板
-(void)createPanelWithData:(HomeData *)data;
@end