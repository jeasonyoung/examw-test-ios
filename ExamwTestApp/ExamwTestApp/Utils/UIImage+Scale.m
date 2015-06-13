//
//  UIImage+Scale.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "UIImage+Scale.h"
//图片缩放扩展
@implementation UIImage (Scale)

#pragma mark 按宽度进行等比缩放
-(UIImage *)scaleWithWidth:(CGFloat)width{
    if(width > 0){
        CGSize sourceSize = self.size;
        CGFloat height = (width * sourceSize.height)/sourceSize.width;
        NSLog(@"开始等比缩放:[%@]=>[%@]",NSStringFromCGSize(sourceSize), NSStringFromCGSize(CGSizeMake(width, height)));
        //1.创建一个bitmapt的context,并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        //2.绘制改变大小的图片
        [self drawInRect:CGRectMake(0, 0, width, height)];
        //3.从当前context中创建改变大小后的图片
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        //4.将当前的context出堆栈
        UIGraphicsEndImageContext();
        //5. 返回改变大小后的图片
        return scaledImage;
    }
    return self;
}

@end
