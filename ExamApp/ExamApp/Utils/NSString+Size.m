//
//  NSString+Size.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "NSString+Size.h"
//计算字符串尺寸实现
@implementation NSString (Size)
-(CGSize)sizeWithFont:(UIFont *)font{
    return [self sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
}
@end
