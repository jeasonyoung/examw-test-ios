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
    NSString *contentText = [self replaceAllContent:text regex:@"(<(/)?p>)" target:@""];
    NSData *textData = [contentText dataUsingEncoding:NSUnicodeStringEncoding allowLossyConversion:YES];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType};
    NSError *err;
    NSMutableAttributedString *textAttri = [[NSMutableAttributedString alloc]initWithData:textData
                                                                                  options:options
                                                                       documentAttributes:nil
                                                                                    error:&err];
    if(err){
        NSLog(@"%@",err);
    }
    return textAttri;
}
#pragma mark 计算Html内容的尺寸
+(CGSize)boundingRectWithHtml:(NSAttributedString *)html constrainedToSize:(CGSize)size{
    if(!html)return CGSizeZero;
    CGRect rect = [html boundingRectWithSize:size
                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                     context:nil];
    return rect.size;
}
#pragma mark 按指定宽度计算Html内容的尺寸
+(CGSize)boundingRectWithHtml:(NSAttributedString *)html constrainedToWidth:(CGFloat)width{
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
#pragma mark 用正则表达式查找第一个匹配的坐标
+(NSRange)findFirstRangeContent:(NSString *)source regex:(NSString *)regex searchRange:(NSRange)searchRange{
    if(source && source.length > 0 && regex && regex.length > 0 && searchRange.location != NSNotFound){
        return [source rangeOfString:regex options:NSRegularExpressionSearch range:searchRange];
    }
    return NSMakeRange(NSNotFound, 0);
}
#pragma mark 利用坐标进行替换
+(NSString *)replaceContent:(NSString *)source rang:(NSRange)range target:(NSString *)target{
    if(source && target && (range.location != NSNotFound)){
        NSMutableString *data = [[NSMutableString alloc]initWithString:source];
        [data replaceCharactersInRange:range withString:target];
        return data;
    }
    return source;
}
#pragma mark 用正则表达式替换第一个匹配的内容
+(NSString *)replaceFirstContent:(NSString *)source regex:(NSString *)regex target:(NSString *)target{
    if(source && source.length > 0 && regex && regex.length > 0 && target){
        NSRange range = [source rangeOfString:regex options:NSRegularExpressionSearch];
        if(range.location != NSNotFound){
            return [self replaceContent:source rang:range target:target];
        }
    }
    return source;
}
#pragma mark 用正则表达式替换
+(NSString *)replaceAllContent:(NSString *)source regex:(NSString *)regex target:(NSString *)target{
    if(source && source.length > 0 && regex && regex.length > 0 && target){
        NSRange range = [source rangeOfString:regex options:NSRegularExpressionSearch];
        if(range.location != NSNotFound){
            NSString *data = [self replaceContent:source rang:range target:target];
            return [self replaceAllContent:data regex:regex target:target];
        }
    }
    return source;
}
@end
