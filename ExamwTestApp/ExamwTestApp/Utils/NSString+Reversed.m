//
//  NSString+Reversed.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/13.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "NSString+Reversed.h"
//字符串反转实现
@implementation NSString (Reversed)
//字符串反转
-(NSString *)reversed{
    NSUInteger len;
    if((len = self.length) > 1){
        NSUInteger i = 0, j = len - 1;
        unichar *characters = malloc(sizeof([self characterAtIndex:0]) * len);
        while (i < j) {
            characters[j] = [self characterAtIndex:i];
            characters[i] = [self characterAtIndex:j];
            i++;
            j--;
        }
        if(i == j){
            characters[i] = [self characterAtIndex:i];
        }
        NSString *result = [NSString stringWithCharacters:characters length:len];
        free(characters);
        return result;
    }
    return self;
}
@end
