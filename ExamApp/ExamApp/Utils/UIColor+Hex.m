//
//  UIColor+Hex.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UIColor+Hex.h"
//从16进制转换颜色
@implementation UIColor (Hex)
#pragma mark 从16进制中转换颜色
+(UIColor *)colorWithHex:(int)hex alpha:(int)alpha{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0x00FF00) >>8))/255.0 blue:((float)(hex &0x0000FF))/255.0 alpha:alpha];
}
#pragma mark 从16进制转换颜色
+(UIColor *)colorWithHex:(int)hex{
    return [UIColor colorWithHex:hex alpha:1];
}

@end
