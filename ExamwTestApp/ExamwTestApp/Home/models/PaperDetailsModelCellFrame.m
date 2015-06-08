//
//  PaperDetailsModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperDetailsModelCellFrame.h"

#import "AppConstants.h"
#import "PaperDetailsModel.h"
#import "PaperModel.h"

#import "NSString+EMAdditions.h"

#define __kPaperDetailsModelCellFrame_top 10//顶部间距
#define __kPaperDetailsModelCellFrame_bottom 10//底部间距
#define __kPaperDetailsModelCellFrame_left 10//左边间距
#define __kPaperDetailsModelCellFrame_right 5//右边间距

#define __kPaperDetailsModelCellFrame_marginV 5//纵向间距
#define __kPaperDetailsModelCellFrame_marginH 25//横向间距

#define __kPaperDetailsModelCellFrame_sourceFormat @"来源:%@"//
#define __kPaperDetailsModelCellFrame_areaFormat @"地区:%@"//
#define __kPaperDetailsModelCellFrame_typeFormat @"类型:%@"//
#define __kPaperDetailsModelCellFrame_yearFormat @"年份:%d"//
#define __kPaperDetailsModelCellFrame_scoreFormat @"总分:%d"//
#define __kPaperDetailsModelCellFrame_totalFormat @"试题数:%d"//
#define __kPaperDetailsModelCellFrame_timeFormat @"时长:%d(分钟)"//

//试卷明细数据模型CellFrame成员变量
@interface PaperDetailsModelCellFrame (){
    CGFloat _maxWith,_centerX;
    UIFont *_font;
}
@end
//试卷明细数据模型CellFrame实现
@implementation PaperDetailsModelCellFrame

#pragma mark 重置初始化
-(instancetype)init{
    if(self = [super init]){
        //字体
        _font = [AppConstants globalListThirdFont];
        //[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        //试卷来源字体
        _sourceFont = _font;
        //所属地区字体
        _areaFont = _font;
        //试卷类型字体
        _typeFont = _font;
        //考试时长字体
        _timeFont = _font;
        //使用年份字体
        _yearFont = _font;
        //试题数字体
        _totalFont = _font;
        //试卷总分字体
        _scoreFont = _font;
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(PaperDetailsModel *)model{
    _model = model;
    //重置
    _descFrame = _sourceFrame = _areaFrame =_typeFrame = _timeFrame = _yearFrame = _totalFrame = _scoreFrame = CGRectZero;
    if(!_model) return;
    NSLog(@"考试明细Cell Frame...");
    _maxWith = SCREEN_WIDTH;
    _centerX = _maxWith / 2;
    _maxWith -= __kPaperDetailsModelCellFrame_right;
    
    NSNumber *outY = [NSNumber numberWithFloat:__kPaperDetailsModelCellFrame_top];
    //1.描述
    //_desc = _model.desc;
    [self setupDescWithOutY:&outY];
    //2.来源和所属地区
    _source = _model.source;
    _area = _model.area;
    [self setupSourceAndAreaWithOutY:&outY];
    //3.试卷类型和使用年份
    if(_model.type > 0){
        _type = [NSString stringWithFormat:__kPaperDetailsModelCellFrame_typeFormat,[PaperModel nameWithPaperType:_model.type]];
    }
    if(_model.year > 0){
        _year = [NSString stringWithFormat:__kPaperDetailsModelCellFrame_yearFormat, (int)_model.year];
    }
    [self setupTypeAndYearWithOutY:&outY];
    //4.试卷总分/试题数/考试时长
    if(_model.score && _model.score.integerValue > 0){
         _score = [NSString stringWithFormat:__kPaperDetailsModelCellFrame_scoreFormat,_model.score.intValue];
    }
    if(_model.total > 0){
        _total = [NSString stringWithFormat:__kPaperDetailsModelCellFrame_totalFormat,(int)_model.total];
    }
    if(_model.time > 0){
         _time = [NSString stringWithFormat:__kPaperDetailsModelCellFrame_timeFormat,(int)_model.time];
    }
    [self setupScoreTotalTimeWithOutY:&outY];
    //5.行高
    _cellHeight = outY.floatValue + __kPaperDetailsModelCellFrame_bottom;
}

//描述
-(void)setupDescWithOutY:(NSNumber **)outY{
    if(_model.desc && _model.desc.length > 0){
        CGFloat x = __kPaperDetailsModelCellFrame_left, y = (*outY).floatValue;
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithAttributedString:[_model.desc attributedString]];
        if(attri){
            //添加字体
            [attri addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, attri.length)];
        }
        _desc = [_model.desc attributedString];
        //尺寸
        CGSize descSize = [_desc boundingRectWithSize:CGSizeMake(_maxWith - x, CGFLOAT_MAX)
                                              options:STR_SIZE_OPTIONS
                                              context:nil].size;
        _descFrame = CGRectMake(x, y, descSize.width, descSize.height);
        y = CGRectGetMaxY(_descFrame) + __kPaperDetailsModelCellFrame_marginV;
        *outY = [NSNumber numberWithFloat:y];
    }
}
//来源和所属地区
-(void)setupSourceAndAreaWithOutY:(NSNumber **)outY{
    CGFloat x = __kPaperDetailsModelCellFrame_left, y = (*outY).floatValue;
    CGFloat maxHeight = 0;
    //来源
    if(_source && _source.length > 0){
        _source = [NSString stringWithFormat:__kPaperDetailsModelCellFrame_sourceFormat,_source];
        CGSize sourceSize = [_source boundingRectWithSize:CGSizeMake(_maxWith - x , CGFLOAT_MAX)
                                                  options:STR_SIZE_OPTIONS
                                               attributes:@{NSFontAttributeName : _sourceFont}
                                                  context:nil].size;
        if(maxHeight < sourceSize.height){
            maxHeight = sourceSize.height;
        }
        _sourceFrame = CGRectMake(x, y, sourceSize.width, sourceSize.height);
        x = CGRectGetMaxX(_sourceFrame) + __kPaperDetailsModelCellFrame_marginH;
    }
    //所属地区
    if(_area && _area.length > 0){
        _area = [NSString stringWithFormat:__kPaperDetailsModelCellFrame_areaFormat,_area];
        CGSize areaSize = [_area boundingRectWithSize:CGSizeMake(_maxWith - x, CGFLOAT_MAX)
                                              options:STR_SIZE_OPTIONS
                                           attributes:@{NSFontAttributeName : _areaFont}
                                              context:nil].size;
        if(maxHeight < areaSize.height){
            maxHeight = areaSize.height;
        }
        CGFloat width = areaSize.width;
        if((x > __kPaperDetailsModelCellFrame_left) && (areaSize.width < _centerX - __kPaperDetailsModelCellFrame_right)){
            x = _centerX;
            width = _centerX - __kPaperDetailsModelCellFrame_right;
        }
        _areaFrame = CGRectMake(x, y, width, areaSize.height);
    }
    if(maxHeight > 0){
        y += maxHeight + __kPaperDetailsModelCellFrame_marginV;
        *outY = [NSNumber numberWithFloat:y];
    }
}
//试卷类型和使用年份
-(void)setupTypeAndYearWithOutY:(NSNumber **)outY{
    CGFloat x = __kPaperDetailsModelCellFrame_left, y = (*outY).floatValue;
    CGFloat maxHeight = 0;
    //试卷类型
    if(_type && _type.length > 0){
        CGSize typeSize = [_type boundingRectWithSize:CGSizeMake(_maxWith - x, CGFLOAT_MAX)
                                              options:STR_SIZE_OPTIONS
                                           attributes:@{NSFontAttributeName : _typeFont}
                                              context:nil].size;
        if(maxHeight < typeSize.height){
            maxHeight = typeSize.height;
        }
        _typeFrame = CGRectMake(x, y, typeSize.width, typeSize.height);
        x = CGRectGetMaxX(_typeFrame) + __kPaperDetailsModelCellFrame_marginH;
    }
    //使用年份
    if(_year && _year.length > 0){
        CGSize yearSize = [_year boundingRectWithSize:CGSizeMake(_maxWith - x, CGFLOAT_MAX)
                                              options:STR_SIZE_OPTIONS
                                           attributes:@{NSFontAttributeName : _yearFont}
                                              context:nil].size;
        if(maxHeight < yearSize.height){
            maxHeight = yearSize.height;
        }
        CGFloat width = yearSize.width;
        if((x > __kPaperDetailsModelCellFrame_left) && (yearSize.width < _centerX - __kPaperDetailsModelCellFrame_right)){
            x = _centerX;
            width = _centerX - __kPaperDetailsModelCellFrame_right;
        }
        _yearFrame = CGRectMake(x, y, width, yearSize.height);
    }
    if(maxHeight > 0){
        y += maxHeight + __kPaperDetailsModelCellFrame_marginV;
        *outY = [NSNumber numberWithFloat:y];
    }
}
//试卷总分/试题数/考试时长
-(void)setupScoreTotalTimeWithOutY:(NSNumber **)outY{
    CGFloat x = __kPaperDetailsModelCellFrame_left, y = (*outY).floatValue,maxHeight = 0;
    NSUInteger count = 0;
    for(NSString *str in @[_score, _total, _time]){
        if(str && str.length > 0){
            count += 1;
        }
    }
    CGFloat width = (_maxWith - x)/count;
    //试卷总分
    if(_score && _score.length > 0){
        CGSize scoreSize = [_score boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                             attributes:@{NSFontAttributeName : _scoreFont}
                                                context:nil].size;
        if(maxHeight < scoreSize.height){
            maxHeight = scoreSize.height;
        }
        _scoreFrame = CGRectMake(x, y, width, scoreSize.height);
        x = CGRectGetMaxX(_scoreFrame);
    }
    //试题数
    if(_total && _total.length > 0){
        CGSize totalSize = [_total boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                             attributes:@{NSFontAttributeName : _totalFont}
                                                context:nil].size;
        if(maxHeight < totalSize.height){
            maxHeight = totalSize.height;
        }
        _totalFrame = CGRectMake(x, y, width, totalSize.height);
        x = CGRectGetMaxX(_totalFrame);
    }
    //考试时长
    if(_time && _time.length > 0){
        CGSize timeSize = [_total boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                options:STR_SIZE_OPTIONS
                                             attributes:@{NSFontAttributeName : _timeFont}
                                                context:nil].size;
        if(maxHeight < timeSize.height){
            maxHeight = timeSize.height;
        }
        _timeFrame = CGRectMake(x, y, width, timeSize.height);
        x = CGRectGetMaxX(_timeFrame);
    }
    if(maxHeight > 0){
        y += maxHeight;
        *outY = [NSNumber numberWithFloat:y];
    }
}
@end
