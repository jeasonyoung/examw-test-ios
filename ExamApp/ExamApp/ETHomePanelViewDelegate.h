//
//  ETImageButtonDelegate.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ETHomePanelView;
//图片按钮代理
@protocol ETHomePanelViewDelegate <NSObject>
//可选
@optional
//图片被点击
-(void)homePanelViewButtonClick:(ETHomePanelView *)homePanelView withTitle:(NSString *)title withValue:(NSString *)value;
@end
