//
//  ETTimerView.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/5.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ETTimerView.h"
//倒计时器视图成员变量
@interface ETTimerView (){
    //显示
    UILabel *_lbTime;
    //定时器
    NSTimer *_timer;
    //倒计时总时间(秒)
    NSInteger _total, _hour,_minute,_second;
}
@end
//倒计时器视图实现
@implementation ETTimerView
#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame Total:(NSInteger)total{
    if(self = [super initWithFrame:frame]){
        _hour = _minute = _second = 0;
        if(total > 0){
            _total = total * 60;
            double result = (double)_total / 3600.0f;
            //取整数部分为时
            _hour = floor(result);
            //将小数部分变为分钟
            result = (result - _hour) * 60;
            //取整数部分为分钟
            _minute = (int)floor(result);
            //取小数分部为秒
            _second = ceil((result - (double)_minute) * 60);
        }
        _lbTime = [[UILabel alloc] initWithFrame:frame];
        _lbTime.textColor = [UIColor blackColor];
        _lbTime.textAlignment = NSTextAlignmentCenter;
        _lbTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)_hour, (long)_minute, (long)_second];
        [self addSubview:_lbTime];
        //定时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self
                                                selector:@selector(scheduledTimer:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    return self;
}
//定时器
-(void)scheduledTimer:(NSTimer *)sender{
    if(sender){
        if(_second + _minute + _hour == 0){
            [sender invalidate];
            return;
        }
        //秒为0
        if(_second == 0){
            //分为0
            if(_minute == 0){
                _hour -= 1;
                _minute = 59;
                _second = 60;
            }else{
                _minute -= 1;
                _second = 60;
            }
        }
        //
        _second -= 1;
        //显示
        if(_lbTime){
            _lbTime.text = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)_hour, (long)_minute, (long)_second];
        }
    }
}
#pragma mark 用时(秒)
-(NSNumber *)useTimes{
    return [NSNumber numberWithInteger:(_total - (_hour *3600 + _minute * 60 + _second))];
}
#pragma mark 停止倒计时
-(NSNumber *)stop{
    if(_timer && _timer.isValid){
        [_timer invalidate];
    }
    return [self useTimes];
}
#pragma mark 转换为BarButtonItem
-(UIBarButtonItem *)toBarButtonItem{
    return [[UIBarButtonItem alloc]initWithCustomView:self];
}
@end
