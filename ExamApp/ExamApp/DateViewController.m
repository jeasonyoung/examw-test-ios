//
//  DateViewController.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "DateViewController.h"
#import "NSDate+TimeZone.h"
#import "HomeData.h"
#import "AppClientSettings.h"
//考试日期设置成员变量
@interface DateViewController (){
    AppClientSettings *_appSettings;
}
@end
//考试日期设置实现
@implementation DateViewController
#pragma mark UI入口
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化设置
    _appSettings = [AppClientSettings clientSettings];
    
    //日期选择器
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(self.view.frame)/2, CGRectGetWidth(self.view.frame)/0.8, 0)];
    datePicker.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];
    datePicker.datePickerMode = UIDatePickerModeDate;
    NSDate *date = _appSettings.appClientExamDate;//[HomeData loadExamDate];
    if(!date){
        date = [NSDate currentLocalTime];
    }
    datePicker.date = date;
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    //
    [self.view addSubview:datePicker];
}
//日期选择器事件
-(void)dateChanged:(UIDatePicker *)sender{
    //NSLog(@"%@",sender.date);
    if(!sender) return;
    [_appSettings updateWithExamDate:sender.date];
    //[HomeData updateExamDate:sender.date];
}
#pragma mark 内存告警
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
