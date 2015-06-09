//
//  ESTimeView.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/9.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "ESTimerView.h"
#import "AppConstants.h"
#import "EffectsUtils.h"
#import "UIColor+Hex.h"

#define __kESTimerView_timeInterval 1.0f//倒计时时间间隔
//倒计时UI成员变量
@interface ESTimerView (){
    UILabel *_lbTime;
    NSTimer *_timer;
    NSInteger _h, _m, _s;
}
@end
//倒计时UI实现
@implementation ESTimerView

#pragma mark 初始化
-(instancetype)initWithTotal:(NSUInteger)totalSec{
    if(self = [super init]){
        self.totalSec = totalSec;
        [self setupInits];
    }
    return self;
}

#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setupInits];
    }
    return self;
}

#pragma mark 重载Frame赋值
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if(_lbTime){
        _lbTime.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    }
}

#pragma mark 总计时秒
-(void)setTotalSec:(NSUInteger)totalSec{
    _totalSec = totalSec;
    if(_totalSec > 0){
        [self resetCouters];
    }
}

//重置计数器
-(void)resetCouters{
    //取时
    double result = (double)(_totalSec / 3600.0f);
    //取整数部分为时
    _h = (int)floor(result);
    //将小数部分转变为分钟
    result = (result - _h) * 60;
    //取整数部分为分钟
    _m = (int)floor(result);
    //取小数部分为秒
    _s = ceil((result - _m) * 60);
}

//初始化
-(void)setupInits{
    //初始化显示
    UIColor *color = [UIColor colorWithHex:GLOBAL_REDCOLOR_HEX];
    _lbTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    _lbTime.textColor = color;
    _lbTime.textAlignment = NSTextAlignmentCenter;
    _lbTime.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    [EffectsUtils addBoundsRadiusWithView:_lbTime BorderColor:color BackgroundColor:[UIColor whiteColor]];
    [self addSubview:_lbTime];
}

//定时处理
-(void)timerFireMethod:(NSTimer *)sender{
    @try {
        //异步线程处理定时时间
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if((_h + _m + _s) <= 0){//计时完毕
                //主线程调用停止方法
                dispatch_async(dispatch_get_main_queue(), ^{
                    //倒计时结束
                    [self stop];
                });
                return;
            }
            //计算倒计时显示
            if(_s == 0){
                if(_m == 0){
                    _h -= 1;
                    _m = 59;
                    _s = 60;
                }else{
                    _m -= 1;
                    _s = 60;
                }
            }
            //计时递减
            _s -= 1;
            //
            NSString *text = [NSString stringWithFormat:@"%02d:%02d:%02d", (int)_h, (int)_m, (int)_s];
//            CGSize textSize = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
//                                                 options:STR_SIZE_OPTIONS
//                                              attributes:@{NSFontAttributeName : _lbTime.font}
//                                                 context:nil].size;
//            NSLog(@"textSize : %@",NSStringFromCGSize(textSize));
            //updateUI
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新时间显示
                if(_lbTime){
                    _lbTime.text = text;
                }
            });
        });
    }
    @catch (NSException *exception) {
        NSLog(@"定时发生异常[%@]:%@", sender.userInfo, exception);
    }
}

#pragma mark 开始计时
-(void)start{
    NSLog(@"开始倒计时:%d", (int)_totalSec);
    if(_timer){
        NSLog(@"倒计时存在，先停止，再启动");
        [self stop];
    }
    //重置秒计数器
    [self resetCouters];
    //开启倒计时
    _timer = [NSTimer scheduledTimerWithTimeInterval:__kESTimerView_timeInterval
                                              target:self
                                            selector:@selector(timerFireMethod:)
                                            userInfo:nil
                                             repeats:YES];
    NSLog(@"倒计时已启动...");
}

#pragma mark 结束计时
-(void)stop{
    NSLog(@"准备停止倒计时...");
    if(_timer && [_timer isValid]){
        //停止倒计时
        [_timer invalidate];
        _timer = nil;
        //处理计时结束代理
        if(_delegate && [_delegate respondsToSelector:@selector(timerView:autoStop:totalUseTimes:)]){
            NSUInteger restSec = (_h * 3600) + (_m * 60) + _s;
            //调用代理方法
            [_delegate timerView:self autoStop:!(restSec > 0) totalUseTimes:(_totalSec - restSec)];
        }
    }
}
@end
