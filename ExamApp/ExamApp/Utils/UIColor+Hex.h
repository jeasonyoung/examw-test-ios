//
//  UIColor+Hex.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)
//从16进制转换
+(UIColor *)colorWithHex:(int)hex;
//从16进制转换
+(UIColor *)colorWithHex:(int)hex alpha:(int)alpha;
@end
