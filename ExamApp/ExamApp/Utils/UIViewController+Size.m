//
//  UIViewController+Size.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UIViewController+Size.h"
//尺寸处理分类实现类
@implementation UIViewController (Size)
#pragma mark 加载顶部高度
-(CGFloat)loadTopHeight{
    CGFloat h = 0;
    if(self.navigationController != nil){
        h += self.navigationController.navigationBar.bounds.size.height;
    }
    if(!self.prefersStatusBarHidden){
        h += 20;
    }
    return h;
}
#pragma mark 加载底部高度
-(CGFloat)loadBottomHeight{
    CGFloat h = 0;
    if(self.tabBarController != nil && !self.tabBarController.tabBar.isHidden){
        h += self.tabBarController.tabBar.bounds.size.height;
    }
    return h;
}
#pragma mark 加载可视视图的Frame
-(CGRect)loadVisibleViewFrame{
    CGFloat top = [self loadTopHeight], bottom = [self loadBottomHeight];
    CGRect visibleTempFrame = self.view.frame;
    visibleTempFrame.origin.y = top;
    visibleTempFrame.size.height -=  (top + bottom);
    return visibleTempFrame;
}
#pragma mark 加载可视视图的中点
-(CGPoint)loadVisibleViewCenter{
    CGFloat top = [self loadTopHeight],bottom = [self loadBottomHeight];
    CGPoint center = self.view.center;
    if((top + bottom) > 0){
        center.y += ((top + bottom) / 2);
    }
    return center;
}
@end
