//
//  UIImage+Scale.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//图片缩放扩展
@interface UIImage (Scale)
//按宽度进行等比缩放
-(UIImage *)scaleWithWidth:(CGFloat)width;
@end
