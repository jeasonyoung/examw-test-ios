//
//  LearnTableViewCell.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "LearnTableViewCell.h"
#import "UIColor+Hex.h"
#import "NSString+Size.h"
#import "NSString+Date.h"

#define __kLearnTableViewCell_top 5//顶部间距
#define __kLearnTableViewCell_left 5//左边间距
#define __kLearnTableViewCell_right 5//右边间距
#define __kLearnTableViewCell_bottom 5//底部间距

#define __kLearnTableViewCell_margin 5//
#define __kLearnTableViewCell_titleFontSize 13//标题字体大小

#define __kLearnTableViewCell_img @"learn_record.png"
#define __kLearnTableViewCell_imgWith 60//96
#define __kLearnTableViewCell_imgHeight 60//96

#define __kLearnTableViewCell_useTimesFontColor 0xFF0000//耗时的字体颜色
#define __kLearnTableViewCell_useTimesFormate @"耗时:%d分%d秒"//

#define __kLearnTableViewCell_scoreFontColor 0xFF0000//得分颜色
#define __kLearnTableViewCell_scoreFormate @"得分:%.1f"//

#define __kLearnTableViewCell_lastTimeFontColor 0xDDA0DD//最后时间
#define __kLearnTableViewCell_lastTimeFormate @"yyyy-MM-dd HH:mm:ss"//
//学习记录列表数据成员变量
@interface LearnTableViewCell (){
    UIImageView *_imgView;
    UILabel *_lbTitle,*_lbUseTimes,*_lbScore,*_lbLastTime;
    UIFont *_titleFont,*_detailFont;
}
@end
//学习记录列表数据实现
@implementation LearnTableViewCell
#pragma mark 重载初始化函数
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _titleFont = [UIFont systemFontOfSize:__kLearnTableViewCell_titleFontSize];
        _detailFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
        //左边图片
        [self setupLeftImageView];
        //标签集合
        [self setupLabelsView];
    }
    return self;
}
//左边图片
-(void)setupLeftImageView{
    _imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:__kLearnTableViewCell_img]];
    _imgView.frame = CGRectMake(__kLearnTableViewCell_left,
                                __kLearnTableViewCell_top,
                                __kLearnTableViewCell_imgWith,
                                __kLearnTableViewCell_imgHeight);
    [self.contentView addSubview:_imgView];
}
//文本标签
-(void)setupLabelsView{
    //标题
    _lbTitle = [[UILabel alloc]init];
    _lbTitle.font = _titleFont;
    _lbTitle.textAlignment = NSTextAlignmentLeft;
    _lbTitle.numberOfLines = 0;
    [self.contentView addSubview:_lbTitle];
    //耗时
    _lbUseTimes = [[UILabel alloc]init];
    _lbUseTimes.font = _detailFont;
    _lbUseTimes.textAlignment = NSTextAlignmentLeft;
    _lbUseTimes.textColor = [UIColor colorWithHex:__kLearnTableViewCell_useTimesFontColor];
    //_lbUseTimes.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:_lbUseTimes];
    //得分
    _lbScore = [[UILabel alloc]init];
    _lbScore.font = _detailFont;
    _lbScore.textAlignment = NSTextAlignmentLeft;
    _lbScore.textColor = [UIColor colorWithHex:__kLearnTableViewCell_scoreFontColor];
    //_lbScore.backgroundColor = [UIColor blueColor];
    [self.contentView addSubview:_lbScore];
    //最后时间
    _lbLastTime = [[UILabel alloc]init];
    _lbLastTime.font = _detailFont;
    _lbLastTime.textAlignment = NSTextAlignmentLeft;
    _lbLastTime.textColor = [UIColor colorWithHex:__kLearnTableViewCell_lastTimeFontColor];
    //_lbLastTime.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:_lbLastTime];
}
#pragma mark 重载选中方法
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark 加载数据
-(CGFloat)loadData{
    //
    if(!_imgView)return 0;
    CGFloat x = CGRectGetMaxX(_imgView.frame);
    NSNumber *y = [NSNumber numberWithFloat:__kLearnTableViewCell_top];
    CGFloat w = CGRectGetWidth(self.frame) - x - __kLearnTableViewCell_right;
    //标题
    [self loadTitleDataWithX:x Y:&y Width:w];
    //耗时
    [self loadUseTimesDataWithX:x Y:&y Width:w];
    //得分
    [self loadScoreDataWithX:x Y:&y Width:w];
    //最后时间
    [self loadLastTimeDataWithX:x Y:&y Width:w];
    //重置高度
    CGFloat maxHeight = CGRectGetMaxY(_imgView.frame);
    if(maxHeight < y.floatValue){
        maxHeight = y.floatValue;
        _imgView.center = CGPointMake(CGRectGetMidX(_imgView.frame), maxHeight/2);
    }
    CGRect tempFrame = self.frame;
    //NSLog(@"0->%@",NSStringFromCGRect(tempFrame));
    tempFrame.size.height = maxHeight + __kLearnTableViewCell_bottom;
    self.frame = tempFrame;
    //NSLog(@"1->%@",NSStringFromCGRect(self.frame));
    return CGRectGetHeight(tempFrame);
}
//加载标题数据(第1行1列)
-(void)loadTitleDataWithX:(CGFloat)x Y:(NSNumber **)y Width:(CGFloat)w{
    if(_lbTitle){
        NSMutableString *title = [NSMutableString string];
        if(_paperTypeName && _paperTypeName.length > 0){
            [title appendFormat:@"[%@]",_paperTypeName];
        }
        if(_paperTitle && _paperTitle.length > 0){
            [title appendFormat:@"%@",_paperTitle];
        }
        if(title.length == 0)return;
        CGSize titleSize = [title sizeWithFont:_lbTitle.font
                             constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        _lbTitle.frame = CGRectMake(x, (*y).floatValue, w, titleSize.height);
        _lbTitle.text = title;
        //重置y坐标
        *y = [NSNumber numberWithFloat:CGRectGetMaxY(_lbTitle.frame)];
    }
}
//加载耗时数据(第2行)
-(void)loadUseTimesDataWithX:(CGFloat)x Y:(NSNumber **)y Width:(CGFloat)w{
    if(_lbUseTimes && _useTimes && _useTimes.floatValue > 0){
        float minute = 0, second = 0;
        if(_useTimes && _useTimes.floatValue > 0){
            minute = _useTimes.floatValue / 60;
            second = (minute - (int)minute) * 60;
        }
        NSString *useTimeText = [NSString stringWithFormat:__kLearnTableViewCell_useTimesFormate,(int)minute,(int)second];
        if(useTimeText.length == 0)return;
        CGSize useTimeTextSize = [useTimeText sizeWithFont:_lbUseTimes.font
                                         constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)
                                             lineBreakMode:NSLineBreakByWordWrapping];
        _lbUseTimes.frame = CGRectMake(x, (*y).floatValue + __kLearnTableViewCell_margin,
                                       w, useTimeTextSize.height);
        _lbUseTimes.text = useTimeText;
        //重置y坐标
        *y = [NSNumber numberWithFloat:CGRectGetMaxY(_lbUseTimes.frame)];
    }else{
        _lbUseTimes.frame = CGRectZero;
    }
}
//加载得分数据(第3行)
-(void)loadScoreDataWithX:(CGFloat)x Y:(NSNumber **)y Width:(CGFloat)w{
    if(_lbScore && _score && _score.floatValue > 0){
        NSString *scoreText = [NSString stringWithFormat:__kLearnTableViewCell_scoreFormate,_score.floatValue];
        if(scoreText.length == 0)return;
        CGSize scoreTextSize = [scoreText sizeWithFont:_lbScore.font
                                     constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)
                                        lineBreakMode:NSLineBreakByWordWrapping];
        _lbScore.frame = CGRectMake(x, (*y).floatValue + __kLearnTableViewCell_margin,
                                    w, scoreTextSize.height);
        _lbScore.text = scoreText;
        //重置y坐标
        *y = [NSNumber numberWithFloat:CGRectGetMaxY(_lbScore.frame)];
    }else{
        _lbScore.frame = CGRectZero;
    }
}
//最后时间(第4行)
-(void)loadLastTimeDataWithX:(CGFloat)x Y:(NSNumber **)y Width:(CGFloat)w{
    if(_lbLastTime && _lastTime){
        NSString *lastTimeText = [NSString stringFromDate:_lastTime withDateFormat:__kLearnTableViewCell_lastTimeFormate];
        if(lastTimeText.length == 0)return;
        CGSize lastTimeTextSize = [lastTimeText sizeWithFont:_lbLastTime.font
                                           constrainedToSize:CGSizeMake(w, CGFLOAT_MAX)
                                               lineBreakMode:NSLineBreakByWordWrapping];
        _lbLastTime.frame = CGRectMake(x, (*y).floatValue + __kLearnTableViewCell_margin,
                                       w, lastTimeTextSize.height);
        _lbLastTime.text = lastTimeText;
        //重置y坐标
        *y = [NSNumber numberWithFloat:CGRectGetMaxY(_lbLastTime.frame)];
    }else{
        _lbLastTime.frame = CGRectZero;
    }
}
@end
