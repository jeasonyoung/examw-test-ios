//
//  NSMutableAttributedString+ImageAttachment.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "NSMutableAttributedString+ImageAttachment.h"
#import "SDWebImageManager.h"
#import "UIImage+Scale.h"
//图片附件处理扩展实现
@implementation NSMutableAttributedString (ImageAttachment)

#pragma mark 追加图片附件
-(void)appendImageAttachmentsWithUrls:(NSArray *)urls imgByWidthScale:(CGFloat)width{
    if(!urls || urls.count == 0)return;
    SDWebImageManager *imgMgr = [SDWebImageManager sharedManager];
    for(NSString *url in urls){
        if(!url || url.length == 0)continue;
        //1.获取图片
        NSString *imgKey = [imgMgr cacheKeyForURL:[NSURL URLWithString:url]];
        UIImage *img = [imgMgr.imageCache imageFromDiskCacheForKey:imgKey];
        if(img){
            //2.按宽度等比缩放图片
            if(width > 0){
                img = [img scaleWithWidth:width];
            }
            CGSize imgSize = img.size;
            //3.图片添加到附件
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = img;
            attachment.bounds = CGRectMake(0, 0, imgSize.width, imgSize.height);
            //4.添加附件到当前字符串
            NSAttributedString *imgAttri = [NSAttributedString attributedStringWithAttachment:attachment];
            [self appendAttributedString:imgAttri];
        }
    }
}
@end
