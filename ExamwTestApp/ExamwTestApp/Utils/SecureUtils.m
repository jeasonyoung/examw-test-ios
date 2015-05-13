//
//  SecureUtils.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SecureUtils.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import "NSData+Hex.h"

#define __kSecureUtils_AES_Algorithm kCCAlgorithmAES128//对称加密算法
#define __kSecureUtils_AES_BlockSize kCCBlockSizeAES128//对称加密向量长度
#define __kSecureUtils_AES_KeySize kCCKeySizeAES256//对称密钥长度

//安全工具类实现
@implementation SecureUtils
#pragma mark MD加密
//二进制md5加密
+(NSData *)md5WithData:(NSData *)data{
    if(data && data.length > 0){
        unsigned char *hash = malloc(CC_MD5_DIGEST_LENGTH);
        CC_MD5(data.bytes, (CC_LONG)data.length, hash);
        NSData *hashData = [NSData dataWithBytes:hash length:CC_MD5_DIGEST_LENGTH];
        free(hash);
        return hashData;
    }
    return data;
}
//将二进制md5为hex
+(NSString *)hexMD5WithData:(NSData *)data{
    if(data && data.length > 0){
        NSData *hash = [self md5WithData:data];
        return [hash toHex];
    }
    return nil;
}
//将字符串md5为hex
+(NSString *)hexMD5WithText:(NSString *)text{
    if(text && text.length > 0){
        return [self hexMD5WithData:[text dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return text;
}
#pragma mark 加密/解密
//密钥384sha
+(NSData *)sha384WithPassword:(NSString *)password{
    unsigned char *sha = malloc(CC_SHA384_DIGEST_LENGTH);
    NSData *pwd = [password dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA384(pwd.bytes, (CC_LONG)pwd.length, sha);
    pwd = [NSData dataWithBytes:sha length:CC_SHA384_DIGEST_LENGTH];
    free(sha);
    return pwd;
}
//对称加/解密操作
+(NSData *)aesWithData:(NSData *)data withPassword:(NSString *)password withOP:(int)op{
    if(data && data.length > 0 && password && password.length > 0){
        CCOperation operation = (CCOperation)op;
        NSData *pwd = [self sha384WithPassword:password];
        //key
        unsigned char ckey[__kSecureUtils_AES_KeySize];
        bzero(ckey, sizeof(ckey));
        [pwd getBytes:ckey length:__kSecureUtils_AES_KeySize];
        //iv
        char civ[__kSecureUtils_AES_BlockSize];
        bzero(civ, sizeof(civ));
        [pwd getBytes:civ length:__kSecureUtils_AES_BlockSize];
        //output buffer
        size_t bufferSize = [data length] + __kSecureUtils_AES_BlockSize;
        void *buffer = malloc(bufferSize);
        //encrypt/decrypt
        size_t outputSize = 0;
        CCCryptorStatus cryptStatus = CCCrypt(operation,
                                              __kSecureUtils_AES_Algorithm,
                                              kCCOptionPKCS7Padding,
                                              ckey,
                                              __kSecureUtils_AES_KeySize,
                                              civ,
                                              [data bytes],
                                              [data length],
                                              buffer,
                                              bufferSize,
                                              &outputSize);
        NSData *result = nil;
        NSString *typeName = (operation == kCCEncrypt ? @"加密" : @"解密");
        if(cryptStatus == kCCSuccess){
            result = [NSData dataWithBytesNoCopy:buffer length:outputSize];
            NSLog(@"%@成功!", typeName);
        }else{
            NSLog(@"%@失败[%d]!", typeName, cryptStatus);
        }
        //free
        free(buffer);
        return result;
    }
    return nil;
}
#pragma mark 加密
//二进制加密
+(NSData *)encyptFromData:(NSData *)data withPassword:(NSString *)password{
    return [self aesWithData:data withPassword:password withOP:kCCEncrypt];
}
//二进制加密为Hex
+(NSString *)hexEncyptFromData:(NSData *)data withPassword:(NSString *)password{
    NSData *encrypt = [self encyptFromData:data withPassword:password];
    if(encrypt){
        return [encrypt toHex];
    }
    return nil;
}
#pragma mark 解密
//二进制解密
+(NSString *)decryptFromData:(NSData *)data withPassword:(NSString *)password{
    if(data && data.length > 0 && password && password.length > 0){
        NSData *decrypt = [self aesWithData:data withPassword:password withOP:kCCDecrypt];
        if(decrypt){
            return [[NSString alloc]initWithData:decrypt encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}
//hex解密
+(NSString *)decryptFromHex:(NSString *)hex withPassword:(NSString *)password{
    if(hex && hex.length > 0 && password && password.length > 0){
        return [self decryptFromData:[NSData dataWithHex:hex] withPassword:password];
    }
    return nil;
}
@end
