//
//  PaperItemTitleModelCellFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/27.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperItemTitleModelCellFrame.h"
#import "PaperItemTitleModel.h"

#import "NSString+EMAdditions.h"

#import "AppConstants.h"

#define __kPaperItemTitleModelCellFrame_top 10//顶部间距
#define __kPaperItemTitleModelCellFrame_bottom 10//底部间距
#define __kPaperItemTitleModelCellFrame_left 10//左边间距
#define __kPaperItemTitleModelCellFrame_right 5//右边间距

//试题标题数据模型CellFrame成员变量
@interface PaperItemTitleModelCellFrame (){
    UIFont *_font;
}
@end

//试题标题数据模型CellFrame实现
@implementation PaperItemTitleModelCellFrame

#pragma mark 重载初始化
-(instancetype)init{
    if(self = [super init]){
        //字体
        _font = [AppConstants globalPaperItemFont];
        
    }
    return self;
}

#pragma mark 设置数据模型
-(void)setModel:(PaperItemTitleModel *)model{
    _model = model;
    _titleFrame = CGRectZero;
    if(!_model || !_model.content)return;
    NSLog(@"设置试题标题数据模型:%@...", _model);
    NSString *titleContent = [self replaceFristContent:_model.content regex:@"([1-9]+\\.)" replace:@""];
    if(_model.order > 0){
        titleContent = [NSString stringWithFormat:@"%d.%@", (int)_model.order, titleContent];
    }
    //默认字体
    [EMStringStylingConfiguration sharedInstance].defaultFont = _font;
    //标题
    _title = [titleContent attributedString];    
    //计算Frame
    CGFloat maxWidth = SCREEN_WIDTH - __kPaperItemTitleModelCellFrame_right;
    CGFloat x = __kPaperItemTitleModelCellFrame_left, y = __kPaperItemTitleModelCellFrame_top;
    CGSize titleSize = [_title boundingRectWithSize:CGSizeMake(maxWidth - x, CGFLOAT_MAX)
                                            options:STR_SIZE_OPTIONS
                                            context:nil].size;
    _titleFrame = CGRectMake(x, y,titleSize.width, titleSize.height);
    _cellHeight = CGRectGetMaxY(_titleFrame) + __kPaperItemTitleModelCellFrame_bottom;
}

//用正则表达式替换
-(NSString *)replaceFristContent:(NSString *)content regex:(NSString *)regex replace:(NSString *)replace{
    if(content && content.length > 0 && regex && regex.length > 0 && replace){
        NSRange range = [content rangeOfString:regex options:NSRegularExpressionSearch];
        if(range.location != NSNotFound){
            NSMutableString *data = [[NSMutableString alloc] initWithString:content];
            [data replaceCharactersInRange:range withString:replace];
            return data;
        }
    }
    return content;
}
@end
