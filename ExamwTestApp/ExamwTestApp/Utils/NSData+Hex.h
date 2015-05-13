//
//  NSData+Hex.h
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import <Foundation/Foundation.h>
//二进制与Hex的转换
@interface NSData (Hex)
//将hex转换为二进制
+(NSData *)dataWithHex:(NSString *)hex;
//将二进制转换为Hex
-(NSString *)toHex;
@end
