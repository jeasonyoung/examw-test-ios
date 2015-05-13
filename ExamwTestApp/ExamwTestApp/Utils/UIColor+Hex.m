//
//  UIColor+Hex.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UIColor+Hex.h"
//十六进制颜色转换扩展实现
@implementation UIColor (Hex)
//十六进制转换为颜色
+(UIColor *)colorWithHex:(int)hex{
    float r = ((float)((hex & 0xFF0000) >> 16))/255.0;
    float g = ((float)((hex & 0x00FF00) >> 8))/255.0;
    float b = ((float)(hex & 0x0000FF))/255.0;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}
@end
