//
//  NSData+Hex.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "NSData+Hex.h"
//2进制转16进制实现
@implementation NSData (Hex)
#pragma mark 转16进制字符串
-(NSString *)dataToHexString{
    NSMutableString *hexString = [NSMutableString string];
    char *chars = (char *)self.bytes;
    for(NSUInteger i = 0; i < self.length; i++){
        //[hexString appendString:[NSString stringWithFormat:@"%0.2hhx",chars[i]]];
        [hexString appendFormat:@"%0.2hhX",chars[i]];
    }
    return hexString;
}
@end
