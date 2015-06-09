//
//  PaperItemAnalysisTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/28.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemAnalysisTableViewCell.h"
#import "AppConstants.h"
#import "PaperItemAnalysisModelCellFrame.h"
#import "UIColor+Hex.h"
#import "TTTAttributedLabel.h"

#define __kPaperItemAnalysisTableViewCell_my_FontColor 0xFFFAFA//字体颜色
//题目答案解析Cell成员变量
@interface PaperItemAnalysisTableViewCell (){
    TTTAttributedLabel *_lbRightAnswers,*_lbMyAnswers,*_lbAnalysis;
}
@end
//题目答案解析Cell实现
@implementation PaperItemAnalysisTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //参考答案
        _lbRightAnswers = [[TTTAttributedLabel alloc] init];
        _lbRightAnswers.textAlignment = NSTextAlignmentLeft;
        _lbRightAnswers.lineBreakMode = NSLineBreakByWordWrapping;
        _lbRightAnswers.lineSpacing = [AppConstants globalLineSpacing];
        _lbRightAnswers.minimumLineHeight = [AppConstants globalLineHeight];
        _lbRightAnswers.numberOfLines = 0;
        //我的答案
        _lbMyAnswers = [[TTTAttributedLabel alloc] init];
        _lbMyAnswers.textColor = [UIColor colorWithHex:__kPaperItemAnalysisTableViewCell_my_FontColor];
        _lbMyAnswers.textAlignment = NSTextAlignmentCenter;
        _lbMyAnswers.lineBreakMode = NSLineBreakByWordWrapping;
        _lbMyAnswers.lineSpacing = [AppConstants globalLineSpacing];
        _lbMyAnswers.minimumLineHeight = [AppConstants globalLineHeight];
        _lbMyAnswers.numberOfLines = 0;
        //题目解析
        _lbAnalysis = [[TTTAttributedLabel alloc] init];
        _lbAnalysis.textAlignment = NSTextAlignmentLeft;
        _lbAnalysis.lineBreakMode = NSLineBreakByWordWrapping;
        _lbAnalysis.lineSpacing = [AppConstants globalLineSpacing];
        _lbAnalysis.minimumLineHeight = [AppConstants globalLineHeight];
        _lbAnalysis.numberOfLines = 0;
        
        //添加到容器
        [self.contentView addSubview:_lbRightAnswers];
        [self.contentView addSubview:_lbMyAnswers];
        [self.contentView addSubview:_lbAnalysis];
    }
    return self;
}

#pragma mark 加载数据模型Cell Frame
-(void)loadModelCellFrame:(PaperItemAnalysisModelCellFrame *)cellFrame{
    NSLog(@"加载题目答案解析数据模型Cell Frame:%@...",cellFrame);
    if(!cellFrame)return;
    //参考答案
    _lbRightAnswers.text = cellFrame.rightAnswers;
    _lbRightAnswers.font = cellFrame.rightAnswersFont;
    _lbRightAnswers.frame = cellFrame.rightAnswersFrame;
    //我的答案
    _lbMyAnswers.text = cellFrame.myAnswers;
    _lbMyAnswers.font = cellFrame.myAnswersFont;
    _lbMyAnswers.frame = cellFrame.myAnswersFrame;
    _lbMyAnswers.backgroundColor = cellFrame.myAnswersBgColor;
    //题目解析
    _lbAnalysis.attributedText = cellFrame.analysis;
    _lbAnalysis.frame = cellFrame.analysisFrame;
}
@end
