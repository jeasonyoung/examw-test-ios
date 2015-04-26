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
+(CGSize)boundingRectWithHtml:(NSAttributedString*)html constrainedToSize:(CGSize)size;
//按指定宽度计算Html内容的尺寸
+(CGSize)boundingRectWithHtml:(NSAttributedString*)html constrainedToWidth:(CGFloat)width;
//用正则表达式查找第一个匹配的内容
+(NSString *)findFirstContent:(NSString *)source regex:(NSString *)regex;
//用正则表达式的坐标数组
+(NSRange)findFirstRangeContent:(NSString *)source regex:(NSString *)regex searchRange:(NSRange)searchRange;
//利用坐标进行替换
+(NSString *)replaceContent:(NSString *)source rang:(NSRange)range target:(NSString *)target;
//用正则表达式替换第一个匹配的内容
+(NSString *)replaceFirstContent:(NSString *)source regex:(NSString *)regex target:(NSString *)target;
//用正则表达式替换
+(NSString *)replaceAllContent:(NSString *)source regex:(NSString *)regex target:(NSString *)target;
@end
