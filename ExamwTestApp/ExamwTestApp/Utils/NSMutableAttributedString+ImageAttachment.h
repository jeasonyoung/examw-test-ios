//
//  NSMutableAttributedString+ImageAttachment.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//图片附件处理扩展
@interface NSMutableAttributedString (ImageAttachment)

//追加图片附件
-(void)appendImageAttachmentsWithUrls:(NSArray *)urls imgByWidthScale:(CGFloat)width;

@end
