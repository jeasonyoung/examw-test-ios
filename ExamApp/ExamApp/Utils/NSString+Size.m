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
#pragma mark 计算字符串尺寸
-(CGSize)sizeWithFont:(UIFont *)font{
    return [self sizeWithAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
}
#pragma mark 计算字符串尺寸
-(CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode{
    CGSize textSize;
    if(CGSizeEqualToSize(size, CGSizeZero)){
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        textSize = [self sizeWithAttributes:attributes];
    }else{
        NSStringDrawingOptions option = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
        //NSStringDrawingTruncatesLastVisibleLine如果文本内容超出指定的矩形限制，文本将被截去并在最后一个字符后加上省略号。如果指定了NSStringDrawingUsesLineFragmentOrigin选项，则该选项被忽略，NSStringDrawingUsesFontLeading计算行高时使用行间距。（字体大小＋行间距＝行高）
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        CGRect rect = [self boundingRectWithSize:size options:option attributes:attributes context:nil];
        textSize = rect.size;
    }
    return textSize;
}
@end
