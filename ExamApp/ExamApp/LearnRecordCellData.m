//
//  LearnRecordCellData.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/16.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//
#import "AppConstants.h"
#import "LearnRecordCellData.h"
#import "LearnRecord.h"

#import "NSString+Size.h"
#import "NSString+Date.h"

#define __kLearnRecordCellData_top 5//顶部间距
#define __kLearnRecordCellData_left 5//左边间距
#define __kLearnRecordCellData_right 5//右边间距
#define __kLearnRecordCellData_bottom 5//底部间距

#define __kLearnRecordCellData_margin 5//

#define __kLearnRecordCellData_titleFontSize 14//__kAppConstants_fontSize//标题字体大小

#define __kLearnRecordCellData_imgWith 60//96
#define __kLearnRecordCellData_imgHeight 60//96

#define __kLearnRecordCellData_useTimesFormate @"耗时:%d分%d秒"//

#define __kLearnRecordCellData_scoreFormate @"得分:%.1f"//

#define __kLearnRecordCellData_lastTimeFormate @"yyyy-MM-dd HH:mm:ss"//

//学习记录数据列表模型成员变量
@interface LearnRecordCellData (){
    UIFont *_font;
}
@end
//学习记录数据列表模型实现
@implementation LearnRecordCellData
#pragma mark 重构初始化
-(instancetype)init{
    if(self = [super init]){
        //_font = [UIFont systemFontOfSize:__kAppConstants_fontSize];
        _font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    }
    return self;
}

#pragma mark 设置学习记录数据
-(void)setRecord:(LearnRecord *)record{
    _record = record;
    //设置图片
    _imgFrame = CGRectMake(__kLearnRecordCellData_left, __kLearnRecordCellData_top,
                           __kLearnRecordCellData_imgWith, __kLearnRecordCellData_imgHeight);
    //
    CGFloat x = CGRectGetMaxX(_imgFrame);
    if(CGRectGetWidth(_imgFrame) > 0){
        x += __kLearnRecordCellData_margin;
    }
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds) - x - __kLearnRecordCellData_right;
    //
    NSNumber *outY = [NSNumber numberWithFloat:__kLearnRecordCellData_top];
    //标题
    [self setupTitleFrameWithX:x Y:&outY Width:width];
    //用时
    [self setupUseTimeFrameWithX:x Y:&outY Width:width];
    //得分
    [self setupScoreFrameWithX:x Y:&outY Width:width];
    //最后时间
    [self setupLastTimeFrameWidthX:x Y:&outY Width:width];
    
    //行高
    CGFloat maxHeight = CGRectGetMaxY(_imgFrame);
    if(outY.floatValue > maxHeight){
        //下移图片的y坐标
        _imgFrame.origin.y += (outY.floatValue - maxHeight)/2;
        maxHeight = outY.floatValue;
    }
    _rowHeight = maxHeight + __kLearnRecordCellData_bottom;
}
//标题
-(void)setupTitleFrameWithX:(CGFloat)x Y:(NSNumber **)y Width:(CGFloat)width {
    //标题字体
    _titleFont = [UIFont systemFontOfSize:__kLearnRecordCellData_titleFontSize];
    //标题
    NSMutableString *titleText = [NSMutableString string];
    //试卷类型
    if(_record && _record.paperTypeName && _record.paperTypeName.length > 0){
        [titleText appendFormat:@"[%@]",_record.paperTypeName];
    }
    //试卷标题
    if(_record && _record.paperTitle && _record.paperTitle.length > 0){
        [titleText appendString:_record.paperTitle];
    }
    //
    if(titleText.length > 0){
        _title = [titleText copy];
        CGSize titleSize = [titleText sizeWithFont:_titleFont
                                 constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                     lineBreakMode:NSLineBreakByWordWrapping];
        _titleFrame = CGRectMake(x, (*y).floatValue, width, titleSize.height);
        //输出y
        *y = [NSNumber numberWithFloat:CGRectGetMaxY(_titleFrame)];
    }else{
        _title = @"";
        _titleFrame = CGRectZero;
    }
}
//用时
-(void)setupUseTimeFrameWithX:(CGFloat)x Y:(NSNumber **)y Width:(CGFloat)width{
    _useTimeFont = _font;
    if(_record && _record.useTimes){
        float minute = 0, second = 0;
        if(_record.useTimes.floatValue > 0){
            minute = _record.useTimes.floatValue / 60;
            second = (minute - (int)minute) * 60;
        }
        _useTime = [NSString stringWithFormat:__kLearnRecordCellData_useTimesFormate,(int)minute,(int)second];
        CGSize useTimeSize = [_useTime sizeWithFont:_useTimeFont
                                  constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                      lineBreakMode:NSLineBreakByWordWrapping];
        _useTimeFrame = CGRectMake(x, (*y).floatValue + __kLearnRecordCellData_margin, width, useTimeSize.height);
        //输出y
        *y = [NSNumber numberWithFloat:CGRectGetMaxY(_useTimeFrame)];
    }else{
        _useTime = @"";
        _useTimeFrame = CGRectZero;
    }
}
//得分
-(void)setupScoreFrameWithX:(CGFloat)x Y:(NSNumber **)y Width:(CGFloat)width{
    _scoreFont = _font;
    if(_record && _record.score && _record.score.floatValue > 0){
        _score = [NSString stringWithFormat:__kLearnRecordCellData_scoreFormate,_record.score.floatValue];
        CGSize scoreSize = [_score sizeWithFont:_scoreFont
                              constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        _scoreFrame = CGRectMake(x, (*y).floatValue + __kLearnRecordCellData_margin, width, scoreSize.height);
        //输出y
        *y = [NSNumber numberWithFloat:CGRectGetMaxY(_scoreFrame)];
    }else{
        _score = @"";
        _scoreFrame = CGRectZero;
    }
}
//最后时间
-(void)setupLastTimeFrameWidthX:(CGFloat)x Y:(NSNumber **)y Width:(CGFloat)width{
    _lastTimeFont = _font;
    if(_record && _record.lastTime){
        _lastTime = [NSString stringFromDate:_record.lastTime withDateFormat:__kLearnRecordCellData_lastTimeFormate];
        CGSize lastTimeSize = [_lastTime sizeWithFont:_lastTimeFont
                                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                                        lineBreakMode:NSLineBreakByWordWrapping];
        _lastTimeFrame = CGRectMake(x, (*y).floatValue + __kLearnRecordCellData_margin, width, lastTimeSize.height);
        //输出y
        *y = [NSNumber numberWithFloat:CGRectGetMaxY(_lastTimeFrame)];
    }else{
        _lastTime = @"";
        _lastTimeFrame = CGRectZero;
    }
}
@end
