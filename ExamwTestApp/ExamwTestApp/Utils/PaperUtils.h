//
//  PaperUtils.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/21.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>

//试卷工具
@interface PaperUtils : NSObject

//加密试卷内容
+(NSString *)encryptPaperContent:(NSString *)content andPassword:(NSString *)pwd;

//解密试卷内容
+(NSString *)decryptPaperContentWithHex:(NSString *)hex andPassword:(NSString *)pwd;

@end
