//
//  PaperUtils.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperUtils.h"

#import "SecureUtils.h"

#define __kPaperUtils_encryptPrefix @"0x"
//试卷工具实现
@implementation PaperUtils

#pragma mark加密
+(NSString *)encryptPaperContent:(NSString *)content andPassword:(NSString *)pwd{
    NSLog(@"加密[key=%@]试卷内容...",pwd);
    if(!content || content.length == 0) return content;
    if([content hasPrefix:__kPaperUtils_encryptPrefix]){
        return content;
    }
    if(!pwd || pwd.length == 0){
        NSLog(@"加密密钥为空!");
        return content;
    }
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"%@%@",__kPaperUtils_encryptPrefix,[SecureUtils hexEncyptFromData:data withPassword:pwd]];
}

#pragma mark 解密
+(NSString *)decryptPaperContentWithHex:(NSString *)hex andPassword:(NSString *)pwd{
    NSLog(@"解密[key=%@]试卷内容...",pwd);
    if(!hex || hex.length == 0) return hex;
    if(![hex hasPrefix:__kPaperUtils_encryptPrefix]){
        return hex;
    }
    NSString *content = [hex substringFromIndex:(__kPaperUtils_encryptPrefix.length)];
    return [SecureUtils decryptFromHex:content withPassword:pwd];
}

@end
