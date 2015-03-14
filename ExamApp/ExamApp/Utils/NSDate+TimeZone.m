//
//  NSDate+TimeZone.m
//  ExamApp
//
//  Created by jeasonyoung on 15/1/23.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "NSDate+TimeZone.h"
//当前时区处理
@implementation NSDate (TimeZone)
#pragma mark 当前时区时间
+(NSDate *)currentLocalTime{
    return [[NSDate date] localTime];
}
#pragma mark 将当前GMT时间转换为本地时间
-(NSDate *)localTime{
    NSDate *current = self;
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:current];
    return [current dateByAddingTimeInterval:interval];
}
#pragma mark 比较两个日期相差的正书天数
-(int)dayIntervalSinceDate:(NSDate *)since{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *current = self;
    NSDateComponents *dateCmp = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:current];
    dateCmp.hour = dateCmp.minute = dateCmp.second = dateCmp.nanosecond = 0;
    NSDate *date = [[cal dateFromComponents:dateCmp] localTime];
    //NSLog(@"date cmp -> date==> %@ = %@ -> %@", current, dateCmp, date);
    
    NSDateComponents *sinceCmp = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:since];
    sinceCmp.hour = sinceCmp.minute = sinceCmp.second = sinceCmp.nanosecond = 0;
    NSDate *sinceDate = [[cal dateFromComponents:sinceCmp] localTime];
    //NSLog(@"since = cmp -> date==> %@ = %@ -> %@", since, sinceCmp, sinceDate);
    
    NSTimeInterval interval = [date timeIntervalSinceDate:sinceDate] / 3600 /24;
    //NSLog(@"interval==> %f", interval);
    
    return (int)interval;
}
@end