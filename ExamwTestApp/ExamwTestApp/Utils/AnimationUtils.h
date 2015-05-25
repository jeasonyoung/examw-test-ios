//
//  AnimationUtils.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//动画工具类
@interface AnimationUtils : NSObject

//三维翻转动画
+(void)mediaTimingEaseInEaseOutWithView:(UIView *)view delegate:(id)delegate;
@end
