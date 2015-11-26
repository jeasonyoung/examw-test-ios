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
    NSDictionary *_attriDict;
}
@end
//试卷结果模型Cell Frame实现
@implementation PaperResultModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        _width = SCREEN_WIDTH;
        _maxWidth = _width - __kPaperResultModelCellFrame_right;
        
        _attriDict = @{NSFontAttributeName : [AppConstants globalListFont]};
        
//        _titleFont = [AppConstants globalListFont];
//        //[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
//        _titleFrame = CGRectZero;
        
//        _contentFont = _titleFont;
//        _contentFontColor = nil;
        _contentFrame = CGRectZero;
        
        _cellHeight = 0;
    }
    return self;
}

//加载数据Frame
-(void)loadDataFrame{
    CGFloat x = __kPaperResultModelCellFrame_left, y = __kPaperResultModelCellFrame_top, maxHeight = 0;
    
    if(_contentAttributedString){
        CGRect contentSize = [_contentAttributedString boundingRectWithSize:CGSizeMake(_maxWidth - x, CGFLOAT_MAX)
                                                                    options:STR_SIZE_OPTIONS
                                                                    context:nil];
        maxHeight = CGRectGetHeight(contentSize);
        contentSize.origin.x = (_maxWidth - x)/2 - CGRectGetWidth(contentSize)/2;
        contentSize.origin.y = y;
        
        _contentFrame = contentSize;
    }
    //行高
    _cellHeight = y + maxHeight + __kPaperResultModelCellFrame_bottom;
}

#pragma mark 加载分数
-(void)loadScoreWithModel:(PaperResultModel *)model{
    if(!model || !model.score)return;
    NSLog(@"加载分数...");
    float score = model.score.floatValue;
    NSString *title = @"得分:";
    NSString *content = [NSString stringWithFormat:@"%@%0.1f",title,score];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:content attributes:_attriDict];
    
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    UIColor *color = [UIColor redColor];
    
    if(score > 60) color = [UIColor greenColor];
    
    NSUInteger titleLen = title.length, contentLen = content.length;
    //添加分数字体/颜色
    [attrString addAttributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : color}
                        range:NSMakeRange(titleLen, contentLen - titleLen)];
    //
    _contentAttributedString = attrString;
    //计算尺寸
    [self loadDataFrame];
}

#pragma mark 加载总题数
-(void)loadTotalWithModel:(PaperResultModel *)model{
    if(!model)return;
    NSLog(@"加载总题数...");
    NSString *content = [NSString stringWithFormat:@"共:%3d题",(int)model.total];
    //
    _contentAttributedString = [[NSAttributedString alloc] initWithString:content
                                                               attributes:_attriDict];
    //
    [self loadDataFrame];
}

#pragma mark 加载做对题数
-(void)loadRightsWithModel:(PaperResultModel *)model{
    if(!model)return;
    NSLog(@"加载做对题数...");
    NSString *content = [NSString stringWithFormat:@"做对:%3d题",(int)model.rights];
    //
    _contentAttributedString = [[NSAttributedString alloc] initWithString:content
                                                               attributes:_attriDict];
    //
    [self loadDataFrame];
}

#pragma mark 加载做错题数
-(void)loadErrorsWithModel:(PaperResultModel *)model{
    if(!model)return;
    NSLog(@"加载做错题数...");
    NSString *content = [NSString stringWithFormat:@"做错:%3d题",(int)model.errors];
    //
    _contentAttributedString = [[NSAttributedString alloc] initWithString:content
                                                               attributes:_attriDict];
    //
    [self loadDataFrame];
}

#pragma mark 加载未做题数
-(void)loadNotsWithModel:(PaperResultModel *)model{
    if(!model)return;
    NSLog(@"加载未做题数...");
    NSString *content = [NSString stringWithFormat:@"未做:%3d题",(int)model.nots];
    //
    _contentAttributedString = [[NSAttributedString alloc] initWithString:content
                                                               attributes:_attriDict];
    //
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
    //
    NSString *content = [NSString stringWithFormat:@"共用时:%@",times];
    //
    _contentAttributedString = [[NSAttributedString alloc] initWithString:content
                                                               attributes:_attriDict];
    //
    [self loadDataFrame];
}

#pragma mark 加载完成时间
-(void)loadTimeWithModel:(PaperResultModel *)model{
    if(!model || !model.lastTime || model.lastTime.length == 0)return;
    //
    NSString *content = [NSString stringWithFormat:@"完成时间:%@",model.lastTime];
    //
    _contentAttributedString = [[NSAttributedString alloc] initWithString:content
                                                               attributes:_attriDict];
    //
    [self loadDataFrame];
}
@end
