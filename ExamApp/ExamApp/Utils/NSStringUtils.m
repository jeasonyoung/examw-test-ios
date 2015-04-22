//
//  NSStringUtils.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/22.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "NSStringUtils.h"
//字符串处理工具类实现
@implementation NSStringUtils
#pragma mark 是否存在包含子字符串
+(BOOL)existContains:(NSString *)text subText:(NSString *)sub{
    if(text && text.length > 0 && sub && sub.length > 0){
        if([text respondsToSelector:@selector(containsString:)]){
            return [text containsString:sub];
        }else{
            NSRange rang = [text rangeOfString:sub];
            return rang.length > 0;
        }
    }
    return NO;
}
#pragma mark 将内容以HTML形式展示
+(NSMutableAttributedString *)toHtmlWithText:(NSString *)text{
    if(!text)return nil;
    text = [self replacementAll:text regex:@"(<(/)?p>)" target:@""];
    NSData *textData = [text dataUsingEncoding:NSUnicodeStringEncoding allowLossyConversion:YES];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType};
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc]initWithData:textData
                                                                                  options:options
                                                                       documentAttributes:nil
                                                                                    error:nil];
    return textAttri;
}
#pragma mark 计算Html内容的尺寸
+(CGSize)boundingRectWithHtml:(NSMutableAttributedString *)html constrainedToSize:(CGSize)size{
    if(!html)return CGSizeZero;
    CGRect rect = [html boundingRectWithSize:size
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     context:nil];
    return rect.size;
}
#pragma mark 按指定宽度计算Html内容的尺寸
+(CGSize)boundingRectWithHtml:(NSMutableAttributedString *)html constrainedToWidth:(CGFloat)width{
    return [self boundingRectWithHtml:html constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
}
#pragma mark 用正则表达式查找第一个匹配的内容
+(NSString *)findFirstContent:(NSString *)source regex:(NSString *)regex{
    if(source && source.length > 0 && regex && regex.length > 0){
        NSRange range = [source rangeOfString:regex options:NSRegularExpressionSearch];
        if(range.location != NSNotFound){
            return [source substringWithRange:range];
        }
    }
    return @"";
}
#pragma mark 用正则表达式替换
+(NSString *)replacementAll:(NSString *)source regex:(NSString *)regex target:(NSString *)target{
    if(source && source.length > 0 && regex && regex.length > 0 && target){
        NSRange range = [source rangeOfString:regex options:NSRegularExpressionSearch];
        if(range.location != NSNotFound){
            NSMutableString *data = [[NSMutableString alloc]initWithString:source];
            [data replaceCharactersInRange:range withString:@""];
            return [self replacementAll:data regex:regex target:target];
        }
    }
    return source;
}
@end
