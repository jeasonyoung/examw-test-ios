//
//  NSString+Hex.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//16进制处理
@interface NSString (Hex)
//将16进制的字符串转换为NSData数据
-(NSData *)hexToBytes;
//将字符串反转
-(NSString *)reversed;
@end
