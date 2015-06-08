//
//  PaperRecordModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperRecordModelCellFrame.h"
#import "PaperRecordModel.h"

#import "AppConstants.h"

#define __kPaperRecordModelCellFrame_top 10//顶部间距
#define __kPaperRecordModelCellFrame_bottom 10//底部间距
#define __kPaperRecordModelCellFrame_left 10//左边间距
#define __kPaperRecordModelCellFrame_right 5//右边间距

#define __kPaperRecordModelCellFrame_marginH 5//横向间距
#define __kPaperRecordModelCellFrame_marginV 5//纵向间距

#define __kPaperRecordModelCellFrame_imgWith 60//图片宽度
#define __kPaperRecordModelCellFrame_imgHeight 60//图片高度

#define __kPaperRecordModelCellFrame_statusYES @"已交卷"
#define __kPaperRecordModelCellFrame_statusNO @"未交卷"
#define __kPaperRecordModelCellFrame_statusFormat @"状态:%@"

#define __kPaperRecordModelCellFrame_scoreFormat @"得分:%.1f"//
#define __kPaperRecordModelCellFrame_rightsFormat @"正确:%d"//
#define __kPaperRecordModelCellFrame_useTimeFormat @"共用时:%@"//

//试卷做题记录数据模型CellFrame实现
@implementation PaperRecordModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //试卷名称字体
        _paperNameFont = [AppConstants globalListFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        //状态字体
        _statusFont = [AppConstants globalListSubFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        //得分字体
        _scoreFont = _statusFont;
        //正确字体
        _rightsFont = _statusFont;
        //用时字体
        _useTimesFont = _statusFont;
        //时间字体
        _timeFont = _statusFont;
        //[AppConstants globalListThirdFont];
    }
    return self;
}

//设置数据模型
-(void)setModel:(PaperRecordModel *)model{
    _model = model;
    //重置
    _imgFrame = _paperNameFrame = _statusFrame = _rightsFrame = CGRectZero;
    _scoreFrame = _useTimesFrame = _timeFrame = CGRectZero;
    //
    if(!_model)return;
    CGFloat width = SCREEN_WIDTH, x = __kPaperRecordModelCellFrame_left, y = __kPaperRecordModelCellFrame_top, maxWith = width - __kPaperRecordModelCellFrame_right, maxHeight = 0;
    //图片(左边第1列)
    _img = [UIImage imageNamed:@"iconRecord.png"];
    _imgFrame = CGRectMake(x, y, __kPaperRecordModelCellFrame_imgWith, __kPaperRecordModelCellFrame_imgHeight);
    x = CGRectGetMaxX(_imgFrame) + __kPaperRecordModelCellFrame_marginH;
    
    //试卷名称(右边第1行)
    _paperName = _model.paperName;
    if(_paperName && _paperName.length > 0){
        CGSize paperNameSize = [_paperName boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                        options:STR_SIZE_OPTIONS
                                                     attributes:@{NSFontAttributeName : _paperNameFont}
                                                        context:nil].size;
        _paperNameFrame = CGRectMake(x, y, paperNameSize.width, paperNameSize.height);
        y = CGRectGetMaxY(_paperNameFrame) + __kPaperRecordModelCellFrame_marginV;
    }
    
    //状态(右边第2行)
    _status = [NSString stringWithFormat:__kPaperRecordModelCellFrame_statusFormat,(_model.status ? __kPaperRecordModelCellFrame_statusYES : __kPaperRecordModelCellFrame_statusNO)];
    CGSize statusSize = [_status boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                              options:STR_SIZE_OPTIONS
                                           attributes:@{NSFontAttributeName : _statusFont}
                                              context:nil].size;
    _statusFrame = CGRectMake(x, y, statusSize.width, statusSize.height);
    y = CGRectGetMaxY(_statusFrame) + __kPaperRecordModelCellFrame_marginV;
    
    //得分(右边第3行1列)
    maxHeight = 0;
    if(_model.status && _model.score){//交卷后才有得分
        _score = [NSString stringWithFormat:__kPaperRecordModelCellFrame_scoreFormat, _model.score.floatValue];
        CGSize scoreSize = [_score boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                             attributes:@{NSFontAttributeName : _scoreFont}
                                                context:nil].size;
        if(maxHeight < scoreSize.height){
            maxHeight = scoreSize.height;
        }
        _scoreFrame = CGRectMake(x, y, scoreSize.width, scoreSize.height);
        x = CGRectGetMaxX(_scoreFrame) + __kPaperRecordModelCellFrame_marginH;
    }
    //正确(右边第3行2列)
    if(_model.status){
        _rights = [NSString stringWithFormat:__kPaperRecordModelCellFrame_rightsFormat,(int)_model.rights];
        CGSize rightSize = [_rights boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                 options:STR_SIZE_OPTIONS
                                              attributes:@{NSFontAttributeName : _rightsFont}
                                                 context:nil].size;
        if(maxHeight < rightSize.height){
            maxHeight = rightSize.height;
        }
        _rightsFrame = CGRectMake(x, y, rightSize.width, rightSize.height);
        x = CGRectGetMaxX(_rightsFrame) + __kPaperRecordModelCellFrame_marginH;
    }
    //用时(右边第3行3列)
    if(_model.status){
        NSUInteger h = 0, m = 0, s = 0;
        if(model.useTimes > 0){
            //时
            double result = (double)model.useTimes/3600.0f;
            h = floor(result);
            //分
            result = (result - h) * 60;
            m = (int)floor(result);
            //秒
            s = ceil((result - m) * 60);
        }
        NSMutableString *times = [NSMutableString string];
        if(h > 0){
            [times appendFormat:@"%dh",(int)h];
        }
        if(m > 0){
            [times appendFormat:@"%d'",(int)m];
        }
        if(s > 0){
            [times appendFormat:@"%d\"",(int)s];
        }
        _useTimes = [NSString stringWithFormat:__kPaperRecordModelCellFrame_useTimeFormat,times];
        CGSize useTimeSize = [_useTimes boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                                     options:STR_SIZE_OPTIONS
                                                  attributes:@{NSFontAttributeName : _useTimesFont}
                                                     context:nil].size;
        if(maxHeight < useTimeSize.height){
            maxHeight = useTimeSize.height;
        }
        _useTimesFrame = CGRectMake(x, y, useTimeSize.width, useTimeSize.height);
    }
    y += maxHeight + __kPaperRecordModelCellFrame_marginV;
    
    //时间(第4行)
    _time = _model.lastTime;
    if(_time && _time.length > 0){
        x = CGRectGetMaxX(_imgFrame) + __kPaperRecordModelCellFrame_marginH;
        CGSize timeSize = [_time boundingRectWithSize:CGSizeMake(maxWith - x, CGFLOAT_MAX)
                                              options:STR_SIZE_OPTIONS
                                           attributes:@{NSFontAttributeName : _timeFont}
                                              context:nil].size;
        _timeFrame = CGRectMake(x, y, timeSize.width, timeSize.height);
        y = CGRectGetMaxY(_timeFrame);
    }
    
    //左右边比较
    if(CGRectGetMaxY(_imgFrame) > y){//左边高于右边,则须右边纵向居中
        //行高
        _cellHeight = CGRectGetMaxY(_imgFrame) + __kPaperRecordModelCellFrame_bottom;
        
        CGFloat padding = (CGRectGetMaxY(_imgFrame) - y)/2;
        CGRect frames[6] = {_paperNameFrame,_statusFrame,_scoreFrame,_rightsFrame,_useTimesFrame,_timeFrame};
        //整体下移
        for(int i = 0; i < 6; i++){
            if(!CGRectEqualToRect(frames[i], CGRectZero)){
                frames[i].origin.y += padding;
            }
        }
    }else{//右边高于左边,则须左边纵向居中
        //行高
        _cellHeight = y + __kPaperRecordModelCellFrame_bottom;
        //
        CGFloat padding = (y - CGRectGetMaxY(_imgFrame))/2;
        _imgFrame.origin.y += padding;
    }
}

@end
