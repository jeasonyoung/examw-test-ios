//
//  PaperItemAnalysisModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemAnalysisModelCellFrame.h"
#import "PaperItemAnalysisModel.h"
#import "PaperItemOptModel.h"

#import "EMStringStylingConfiguration.h"
#import "NSString+EMAdditions.h"
#import "NSMutableAttributedString+ImageAttachment.h"

#import "UIColor+Hex.h"

#import "AppConstants.h"

#define __kPaperItemAnalysisModelCellFrame_top 10//顶部间距
#define __kPaperItemAnalysisModelCellFrame_bottom 10//底部间距
#define __kPaperItemAnalysisModelCellFrame_left 10//左边间距
#define __kPaperItemAnalysisModelCellFrame_right 10//右边间距

#define __kPaperItemOptModelCellFrame_marginV 8//纵向间距

#define __kPaperItemAnalysisModelCellFrame_answerRegex @"([A-Z]\\.)"//答案正则表达式
#define __kPaperItemAnalysisModelCellFrame_rightFormat @"参考答案:%@"//

#define __kPaperItemAnalysisModelCellFrame_my_padding 5//内间距
#define __kPaperItemAnalysisModelCellFrame_my_Right @" √ 答对了"//
//#define __kPaperItemAnalysisModelCellFrame_my_RightBgColor 0x008B00//背景色
#define __kPaperItemAnalysisModelCellFrame_my_Wrong @" × 答错了"//
//#define __kPaperItemAnalysisModelCellFrame_my_WrongBgColor 0xFF0000//背景色

#define __kPaperItemAnalysisModelCellFrame_analysis @"题目解析:%@"//
//试题答案解析数据模型CellFrame成员变量
@interface PaperItemAnalysisModelCellFrame (){
    UIFont *_font;
    CGFloat _maxWith;
}
@end
//试题答案解析数据模型CellFrame实现
@implementation PaperItemAnalysisModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //字体
        _font = [AppConstants globalPaperItemFont];//[UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _rightAnswersFont = _font;
        _myAnswersFont = _font;//[UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(PaperItemAnalysisModel *)model{
    _model = model;
    //重置
    _rightAnswersFrame = _myAnswersFrame = _analysisFrame = CGRectZero;
    if(!_model)return;
    NSLog(@"设置试题答案解析数据模型[%@]...",_model);
    _maxWith = SCREEN_WIDTH - __kPaperItemAnalysisModelCellFrame_right;
    
    NSNumber *y = [NSNumber numberWithFloat:__kPaperItemAnalysisModelCellFrame_top];
    //答案
    [self setupAnswersWithOutY:&y];
    //题目解析
    [self setupAnalysisWithOutY:&y];
    //行高
    _cellHeight = y.floatValue + __kPaperItemAnalysisModelCellFrame_bottom;
}

//设置答案
-(void)setupAnswersWithOutY:(NSNumber **)outy{
    if(!_model.options || _model.options.count == 0)return;
    
    CGFloat x = __kPaperItemAnalysisModelCellFrame_left, y = (*outy).floatValue,maxHeight = 0;
    //参考答案
    if(_model.rightAnswers && _model.options.count > 0){
        NSMutableString *answers = [NSMutableString string];
        for(PaperItemOptModel *optModel in _model.options){
            if(!optModel)continue;
            NSRange range = [_model.rightAnswers rangeOfString:optModel.Id];
            if(range.location != NSNotFound){
                NSString *rightAnswer = [self findFristContent:optModel.content
                                                         regex:__kPaperItemAnalysisModelCellFrame_answerRegex];
                if(rightAnswer && rightAnswer.length > 0){
                    if([rightAnswer hasSuffix:@"."]){
                        rightAnswer = [rightAnswer substringWithRange:NSMakeRange(0, rightAnswer.length - 1)];
                    }
                    [answers appendString:rightAnswer];
                }
            }
        }
        if(answers.length > 0){
            _rightAnswers = [NSString stringWithFormat:__kPaperItemAnalysisModelCellFrame_rightFormat,answers];
            CGSize rightAnswersSize = [_rightAnswers boundingRectWithSize:CGSizeMake(_maxWith - x, CGFLOAT_MAX)
                                                                  options:STR_SIZE_OPTIONS
                                                               attributes:@{NSFontAttributeName : _rightAnswersFont}
                                                                  context:nil].size;
            if(maxHeight < rightAnswersSize.height){
                maxHeight = rightAnswersSize.height;
            }
            _rightAnswersFrame = CGRectMake(x, y, rightAnswersSize.width, rightAnswersSize.height);
            x = CGRectGetMaxX(_rightAnswersFrame);
        }
    }
    //我的答案
    BOOL isMyRight = NO;
    if(_model.myAnswers && _model.myAnswers.length > 0 && _model.rightAnswers){
        //多个答案以,分隔
        NSArray *arrays = [_model.myAnswers componentsSeparatedByString:@","];
        for(NSString *strValue in arrays){
            if(!strValue || strValue.length == 0)continue;
            NSRange range = [_model.rightAnswers rangeOfString:strValue];
            isMyRight = (range.location != NSNotFound);
        }
    }
    _myAnswers = isMyRight ? __kPaperItemAnalysisModelCellFrame_my_Right : __kPaperItemAnalysisModelCellFrame_my_Wrong;
    _myAnswersBgColor = [UIColor colorWithHex:(isMyRight ? GLOBAL_ITEM_RIGHT_COLOR : GLOBAL_ITEM_WRONG_COLOR)];
    CGSize myAnswersSize = [_myAnswers boundingRectWithSize:CGSizeMake(_maxWith - x, CGFLOAT_MAX)
                                                    options:STR_SIZE_OPTIONS
                                                 attributes:@{NSFontAttributeName : _myAnswersFont}
                                                    context:nil].size;
    if(maxHeight < myAnswersSize.height + __kPaperItemAnalysisModelCellFrame_my_padding){
        maxHeight = myAnswersSize.height + __kPaperItemAnalysisModelCellFrame_my_padding;
    }
    if(x > __kPaperItemAnalysisModelCellFrame_left){
        x = _maxWith - myAnswersSize.width - __kPaperItemAnalysisModelCellFrame_my_padding;
    }
    _myAnswersFrame = CGRectMake(x, y,
                                 myAnswersSize.width + __kPaperItemAnalysisModelCellFrame_my_padding,
                                 myAnswersSize.height + __kPaperItemAnalysisModelCellFrame_my_padding);
    y += maxHeight + __kPaperItemOptModelCellFrame_marginV;
    *outy = [NSNumber numberWithFloat:y];
}

//设置题目解析
-(void)setupAnalysisWithOutY:(NSNumber **)outy{
    CGFloat x = __kPaperItemAnalysisModelCellFrame_left, y = (*outy).floatValue;
    if(_model.content && _model.content.length > 0){
        //默认字体
        [EMStringStylingConfiguration sharedInstance].defaultFont = _font;
        //答案解析内容
        NSMutableAttributedString *contentAttri = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSString stringWithFormat:__kPaperItemAnalysisModelCellFrame_analysis,_model.content] attributedString]];
        //图片处理
        [contentAttri appendImageAttachmentsWithUrls:_model.images imgByWidthScale:(_maxWith - x)];
        
        _analysis = contentAttri;
        CGSize analysisSize = [_analysis boundingRectWithSize:CGSizeMake(_maxWith - x, CGFLOAT_MAX)
                                                      options:STR_SIZE_OPTIONS
                                                      context:nil].size;
        _analysisFrame = CGRectMake(x, y, analysisSize.width, analysisSize.height);
        y = CGRectGetMaxY(_analysisFrame);
        *outy = [NSNumber numberWithFloat:y];
    }
}

//用正则表达式查找匹配的第一个内容
-(NSString *)findFristContent:(NSString *)content regex:(NSString *)regex{
    if(content && content.length > 0 && regex && regex.length > 0){
        NSRange range = [content rangeOfString:regex options:NSRegularExpressionSearch];
        if(range.location != NSNotFound){
            return [content substringWithRange:range];
        }
    }
    return @"";
}
@end
