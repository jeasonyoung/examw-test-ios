//
//  AESCrypt.h
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//加密/解密工具类
@interface AESCrypt : NSObject
//数据MD5加密
+(NSString *)md5SumFromData:(NSData *)data;
//字符串MD5加密
+(NSString *)md5SumFromString:(NSString *)message;
//字符串加密
+(NSString *)encryptFromString:(NSString *)message password:(NSString *)pwd;
//字符串解密
+(NSString *)decryptFromString:(NSString *)hexCryptograph password:(NSString *)pwd;
//数据加密
+(NSData *)encryptFromData:(NSData *)data password:(NSData *)pwd;
//数据解密
+(NSData *)decryptFromData:(NSData *)data password:(NSData *)pwd;
@end
