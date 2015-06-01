//
//  PaperResultModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperResultModelCellFrame.h"
#import "PaperResultModel.h"

#import "AppConstants.h"

#define __kPaperResultModelCellFrame_top 5//顶部间距
#define __kPaperResultModelCellFrame_left 5//顶部间距
#define __kPaperResultModelCellFrame_bottom 5//顶部间距
#define __kPaperResultModelCellFrame_right 5//顶部间距

//试卷结果模型Cell Frame成员变量
@interface PaperResultModelCellFrame (){
    CGFloat _width,_maxWidth;
}
@end
//试卷结果模型Cell Frame实现
@implementation PaperResultModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _width = SCREEN_WIDTH;
        _maxWidth = _width - __kPaperResultModelCellFrame_right;
        
        _titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _titleFrame = CGRectZero;
        
        _contentFont = _titleFont;
        _contentFontColor = nil;
        _contentFrame = CGRectZero;
        
        _cellHeight = 0;
    }
    return self;
}

//加载数据Frame
-(void)loadDataFrame{
    CGFloat x=__kPaperResultModelCellFrame_left, y=__kPaperResultModelCellFrame_top,maxHeight=0;
    CGSize titleSize = CGSizeZero, contentSize = CGSizeZero;
    //标题尺寸
    if(_title && _title.length > 0){
        titleSize = [_title boundingRectWithSize:CGSizeMake(_maxWidth - x, CGFLOAT_MAX)
                                         options:STR_SIZE_OPTIONS
                                      attributes:@{NSFontAttributeName : _titleFont}
                                         context:nil].size;
        if(maxHeight < titleSize.height){ maxHeight = titleSize.height;}
    }
    //内容尺寸
    if(_content && _content.length > 0){
        contentSize = [_content boundingRectWithSize:CGSizeMake(_maxWidth - x, CGFLOAT_MAX)
                                             options:STR_SIZE_OPTIONS
                                          attributes:@{NSFontAttributeName : _contentFont} context:nil].size;
        if(maxHeight < contentSize.height){ maxHeight = contentSize.height;}
    }
    //标题frame
    if(!CGSizeEqualToSize(titleSize, CGSizeZero)){
        x = _width/2 - titleSize.width;
        y = __kPaperResultModelCellFrame_top + (maxHeight - titleSize.height);
        _titleFrame = CGRectMake(x, y, titleSize.width, titleSize.height);
        x = CGRectGetMaxX(_titleFrame);
    }
    //内容frame
    if(!CGSizeEqualToSize(contentSize, CGSizeZero)){
        y = __kPaperResultModelCellFrame_top + (maxHeight - contentSize.height)/2;
        _contentFrame = CGRectMake(x, y, contentSize.width, contentSize.height);
    }
    //行高
    _cellHeight = y + maxHeight + __kPaperResultModelCellFrame_bottom;
}

#pragma mark 加载分数
-(void)loadScoreWithModel:(PaperResultModel *)model{
    if(!model || !model.score)return;
    NSLog(@"加载分数...");
    _title = @"得分:";
    float score = model.score.floatValue;
    _content = [NSString stringWithFormat:@"%0.1f", score];
    _contentFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    if(score > 60){
        _contentFontColor = [UIColor greenColor];
    }else{
        _contentFontColor = [UIColor redColor];
    }
    [self loadDataFrame];
}

#pragma mark 加载总题数
-(void)loadTotalWithModel:(PaperResultModel *)model{
    if(!model)return;
    NSLog(@"加载总题数...");
    _title = @"共:";
    _content = [NSString stringWithFormat:@"%d题",(int)model.total];
    [self loadDataFrame];
}

#pragma mark 加载做对题数
-(void)loadRightsWithModel:(PaperResultModel *)model{
    if(!model)return;
    NSLog(@"加载做对题数...");
    _title = @"做对:";
    _content = [NSString stringWithFormat:@"%d题", (int)model.rights];
    [self loadDataFrame];
}

#pragma mark 加载做错题数
-(void)loadErrorsWithModel:(PaperResultModel *)model{
    if(!model)return;
    NSLog(@"加载做错题数...");
    _title = @"做错:";
    _content = [NSString stringWithFormat:@"%d题", (int)model.errors];
    [self loadDataFrame];
}

#pragma mark 加载未做题数
-(void)loadNotsWithModel:(PaperResultModel *)model{
    if(!model)return;
    NSLog(@"加载未做题数...");
    _title = @"未做:";
    _content = [NSString stringWithFormat:@"%d题", (int)model.nots];
    [self loadDataFrame];
}

#pragma mark 加载用时
-(void)loadUseTimeWithModel:(PaperResultModel *)model{
    if(!model)return;
    NSLog(@"加载用时...");
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
    _title = @"共用时:";
    _content = times;
    [self loadDataFrame];
}

#pragma mark 加载完成时间
-(void)loadTimeWithModel:(PaperResultModel *)model{
    if(!model || !model.lastTime || model.lastTime.length == 0)return;
    _title = @"完成时间:";
    _content = model.lastTime;
    [self loadDataFrame];
}
@end
