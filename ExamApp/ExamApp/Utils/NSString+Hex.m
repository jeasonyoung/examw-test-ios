//
//  NSString+Hex.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "NSString+Hex.h"
//16进制处理实现分类
@implementation NSString (Hex)
#pragma mark 将16进制的字符串转换为NSData数据
-(NSData *)hexToBytes{
    if(self.length == 0 || (self.length % 2 != 0)) return nil;
    NSMutableData *data = [NSMutableData data];
    
    char byte_char[3] = {'\0','\0','\0'};
    for(int i = 0; i < (self.length / 2); i++){
        byte_char[0] = [self characterAtIndex:(i*2)];
        byte_char[1] = [self characterAtIndex:(i*2 + 1)];
        long hex = strtol(byte_char, NULL, 16);
        [data appendBytes:&hex length:1];
    }
    return data;
}
#pragma mark 将字符串反转
-(NSString *)reversed{
    if(self.length <= 1) return self;
    long i = 0, j = self.length - 1;
    unichar *characters = malloc(sizeof([self characterAtIndex:0]) * self.length);
    while(i < j){
        characters[j] = [self characterAtIndex:i];
        characters[i] = [self characterAtIndex:j];
        i++;
        j--;
    }
    if(i == j){
        characters[i] = [self characterAtIndex:i];
    }
    NSString *result = [NSString stringWithCharacters:characters length:self.length];
    free(characters);
    NSLog(@"reversed> %@ <=> %@", self, result);
    return result;
}
@end
