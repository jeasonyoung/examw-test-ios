//
//  UIColor+Hex.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>
//十六进制颜色转换扩展
@interface UIColor (Hex)
//十六进制转换为颜色
+(UIColor *)colorWithHex:(int)hex;
@end
