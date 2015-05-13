//
//  SecureUtils.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//安全工具类
@interface SecureUtils : NSObject
//md5加密为二进制
+(NSData *)md5WithData:(NSData *)data;
//md5加密为Hex
+(NSString *)hexMD5WithData:(NSData *)data;
//md5加密为Hex
+(NSString *)hexMD5WithText:(NSString *)text;

//对称加密为二进制
+(NSData *)encyptFromData:(NSData *)data withPassword:(NSString *)password;
//对称加密为Hex字符串
+(NSString *)hexEncyptFromData:(NSData *)data withPassword:(NSString *)password;

//对称解密为明文
+(NSString *)decryptFromData:(NSData *)data withPassword:(NSString *)password;
//对称解密为明文
+(NSString *)decryptFromHex:(NSString *)hex withPassword:(NSString *)password;
@end
