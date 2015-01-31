//
//  AESCrypt.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "AESCrypt.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import "NSData+Hex.h"
#import "NSString+Hex.h"


#define __k_AES_ALGORITHM kCCAlgorithmAES128//对称加密算法
#define __k_AES_BLOCK_SIZE kCCBlockSizeAES128//对称加密向量长度
#define __k_AES_KEY_SIZE kCCKeySizeAES256//对称密钥长度
//加密/解密工具类
@implementation AESCrypt
#pragma mark 将字符串MD5加密
+(NSString *)md5SumFromString:(NSString *)message{
    if(message == nil || message.length == 0) return nil;
    return [AESCrypt md5SumFromData:[message dataUsingEncoding:NSUTF8StringEncoding]];
}
#pragma mark 将数据MD5
+(NSString *)md5SumFromData:(NSData *)data{
    if(data == nil || data.length == 0) return nil;
    NSData *md5_data = [AESCrypt md5Sum:data];
    return [md5_data dataToHexString];
}
//md5内部方法
+(NSData *)md5Sum:(NSData *)data{
    unsigned char *hash;
    hash = malloc(CC_MD5_DIGEST_LENGTH);
    CC_MD5(data.bytes, (CC_LONG)data.length, hash);
    NSData *md5_data = [NSData dataWithBytes:hash length:CC_MD5_DIGEST_LENGTH];
    free(hash);
    return md5_data;
}
#pragma mark 字符串对称加密
+(NSString *)encryptFromString:(NSString *)message password:(NSString *)pwd{
    if(message == nil || message.length == 0 || pwd == nil || pwd.length == 0) return nil;
    NSData *message_data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encypt_data = [AESCrypt encryptFromData:message_data
                                           password:[pwd dataUsingEncoding:NSUTF8StringEncoding]];
    return [encypt_data dataToHexString];
}
#pragma mark 字符串对称解密
+(NSString *)decryptFromString:(NSString *)hexCryptograph password:(NSString *)pwd{
    if(hexCryptograph == nil || hexCryptograph.length == 0 || pwd == nil || pwd.length == 0) return nil;
    NSData *hex_data = [hexCryptograph hexToBytes];
    if(hex_data == nil || hex_data.length == 0) return nil;
    NSData *decrypt_data = [AESCrypt decryptFromData:hex_data
                                            password:[pwd dataUsingEncoding:NSUTF8StringEncoding]];
    if(decrypt_data){
        return [[NSString alloc] initWithData:decrypt_data
                                     encoding:NSUTF8StringEncoding];
    }
    return nil;
}
#pragma mark 数据对称加密
+(NSData *)encryptFromData:(NSData *)data password:(NSData *)pwd{
    NSData *result = nil;
    if(data == nil || data.length == 0 || pwd == nil || pwd.length == 0) return result;
    //
    NSData *aes_pwd = [AESCrypt sha384WithData:pwd];
    //setup key
    unsigned char ckey[__k_AES_KEY_SIZE];
    bzero(ckey, sizeof(ckey));
    [aes_pwd getBytes:ckey length:__k_AES_KEY_SIZE];
    
    //setup iv
    char cIv[__k_AES_BLOCK_SIZE];
    bzero(cIv, sizeof(cIv));
    [aes_pwd getBytes:cIv length:__k_AES_BLOCK_SIZE];
    
    //setup ouput buffer
    size_t bufferSize = [data length] + __k_AES_BLOCK_SIZE;
    void *buffer = malloc(bufferSize);

    //do encrypt
    size_t encryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          __k_AES_ALGORITHM,
                                          kCCOptionPKCS7Padding,
                                          ckey,
                                          __k_AES_KEY_SIZE,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &encryptedSize);
    if(cryptStatus == kCCSuccess){
        result = [NSData dataWithBytesNoCopy:buffer length:encryptedSize];
    }else{
        free(buffer);
        NSLog(@"[ERROR] failed to encrypt|CCCryptoStatus: %d", cryptStatus);
    }
    return result;
}
#pragma mark 数据对称解密
+(NSData *)decryptFromData:(NSData *)data password:(NSData *)pwd{
    NSData *result = nil;
    if(data == nil || data.length == 0 || pwd == nil || pwd.length == 0) return result;
    //
     NSData *aes_pwd = [AESCrypt sha384WithData:pwd];
    //setup key
    unsigned char ckey[__k_AES_KEY_SIZE];
    bzero(ckey, sizeof(ckey));
    [aes_pwd getBytes:ckey length:__k_AES_KEY_SIZE];
    
    //setup iv
    char cIv[__k_AES_BLOCK_SIZE];
    bzero(cIv, sizeof(cIv));
    [aes_pwd getBytes:cIv length:__k_AES_BLOCK_SIZE];
    
    //setup output buffer
    size_t bufferSize = [data length] + __k_AES_BLOCK_SIZE;
    void *buffer = malloc(bufferSize);
    
    //do decrypt
    size_t decryptedSize = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          __k_AES_ALGORITHM,
                                          kCCOptionPKCS7Padding,
                                          ckey,
                                          __k_AES_KEY_SIZE,
                                          cIv,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          bufferSize,
                                          &decryptedSize);
    if(cryptStatus == kCCSuccess){
        result = [NSData dataWithBytesNoCopy:buffer length:decryptedSize];
    }else{
        free(buffer);
        NSLog(@"[ERROR] failed to decrypt| CCCryptoStatus: %d", cryptStatus);
    }
    return result;
}
//
+(NSData *)sha384WithData:(NSData *)hashData{
    unsigned char *digest;
    digest = malloc(CC_SHA384_DIGEST_LENGTH);
    CC_SHA384(hashData.bytes, (CC_LONG)hashData.length, digest);
    NSData *sha = [NSData dataWithBytes:digest length:CC_SHA384_DIGEST_LENGTH];
    free(digest);
    return sha;
}
@end
