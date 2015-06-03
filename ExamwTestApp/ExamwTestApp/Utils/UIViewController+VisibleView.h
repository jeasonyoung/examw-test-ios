//
//  UIViewController+VisibleView.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//可视视图控制器扩展
@interface UIViewController (VisibleView)
//加载顶部高度
-(CGFloat)loadTopHeight;
//加载底部高度
-(CGFloat)loadBottomHeight;
//加载可视视图的Frame
-(CGRect)loadVisibleViewFrame;
//加载可视视图的中点
-(CGPoint)loadVisibleViewCenter;
@end
