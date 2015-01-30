//
//  NSData+Hex.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//2进制转16进制
@interface NSData (Hex)
//转16进制字符串
-(NSString *)dataToHexString;
@end
