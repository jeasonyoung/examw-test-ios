//
//  NSData+Hex.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "NSData+Hex.h"
//二进制与Hex的转换实现
@implementation NSData (Hex)
//将Hex转为二进制
+(NSData *)dataWithHex:(NSString *)hex{
    if(hex && hex.length > 0 && (hex.length % 2 == 0)){
        char byte_char[3] = {'\0','\0','\0'};
        NSUInteger len = hex.length / 2;
        NSMutableData *data = [NSMutableData data];
        for(NSUInteger i = 0; i < len; i++){
            byte_char[0] = [hex characterAtIndex:(i * 2)];
            byte_char[1] = [hex characterAtIndex:(i * 2 + 1)];
            long _hex = strtol(byte_char, NULL, 16);
            [data appendBytes:&_hex length:1];
        }
        return data;
    }
    return nil;
}
//将二进制转为Hex
-(NSString *)toHex{
    NSMutableString *hex = [NSMutableString string];
    char *chars = (char*)self.bytes;
    NSUInteger len = self.length;
    for(NSUInteger i = 0; i < len; i++){
        [hex appendFormat:@"%0.2hhx",chars[i]];
    }
    return hex;
}
@end
