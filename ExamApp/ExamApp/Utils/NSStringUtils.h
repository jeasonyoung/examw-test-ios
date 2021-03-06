//
//  NSStringUtils.h
//  ExamApp
//
//  Created by jeasonyoung on 15/4/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//字符串处理工具类
@interface NSStringUtils : NSObject
//是否存在子字符串
+(BOOL)existContains:(NSString *)text subText:(NSString *)sub;
//将内容以HTML形式展示
+(NSMutableAttributedString *)toHtmlWithText:(NSString *)text;
//计算Html内容的尺寸
+(CGSize)boundingRectWithHtml:(NSMutableAttributedString*)html constrainedToSize:(CGSize)size;
//按指定宽度计算Html内容的尺寸
+(CGSize)boundingRectWithHtml:(NSMutableAttributedString*)html constrainedToWidth:(CGFloat)width;
//用正则表达式查找第一个匹配的内容
+(NSString *)findFirstContent:(NSString *)source regex:(NSString *)regex;
//用正则表达式替换
+(NSString *)replacementAll:(NSString *)source regex:(NSString *)regex target:(NSString *)target;
@end
