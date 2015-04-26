//
//  PaperDetailModel.m
//  ExamApp
//
//  Created by jeasonyoung on 15/4/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperDetailModel.h"
#import "NSStringUtils.h"

//试卷明细数据模型实现
@implementation PaperDetailModel
#pragma mark 初始化
-(instancetype)initWithType:(NSUInteger)type title:(NSString *)title{
    if(self = [super init]){
        _type = type;
        _title = title;
    }
    return self;
}
#pragma mark 静态初始化
+(instancetype)modelWithType:(NSUInteger)type title:(NSString *)title{
    return [[self alloc]initWithType:type title:title];
}
@end

#define __kPaperDetailModelFrame_top 5//上部间距
#define __kPaperDetailModelFrame_left 5//左边间距
#define __kPaperDetailModelFrame_right 5//右边间距
#define __kPaperDetailModelFrame_bottom 5//底部间距
#define __kPaperDetailModelFrame_fontSize 14//标题字体大小

#define __kPaperDetailModelFrame_btnHeight 30//按钮高度
//试卷明细数据模型Frame成员变量
@interface PaperDetailModelFrame (){
    UIFont *_font;
}
@end
//试卷明细数据模型Frame实现
@implementation PaperDetailModelFrame
-(instancetype)init{
    if(self = [super init]){
        _font = [UIFont systemFontOfSize:__kPaperDetailModelFrame_fontSize];
    }
    return self;
}
#pragma mark 设置模型数据
-(void)setModel:(PaperDetailModel *)model{
    if((_model = model)){
        _modelType = _model.type;
        CGFloat maxWidth=CGRectGetWidth([[UIScreen mainScreen] bounds])-__kPaperDetailModelFrame_left-__kPaperDetailModelFrame_right;
        CGFloat y = __kPaperDetailModelFrame_top;
        switch (_modelType) {
            case __kPaperDetailModel_typeTitle://标题
            case __kPaperDetailModel_typeDesc://描述
            {
                NSString *title = _model.title;
                NSMutableAttributedString *titleAttri = [NSStringUtils toHtmlWithText:title];
                //[titleAttri addAttribute:NSFontAttributeName value:_font range:NSMakeRange(0, title.length)];
                CGSize titleAttriSize = [NSStringUtils boundingRectWithHtml:titleAttri constrainedToWidth:maxWidth];
                _titleFrame = CGRectMake(__kPaperDetailModelFrame_left, y, maxWidth, titleAttriSize.height);
                _titleAttri = titleAttri;
                break;
            }
            case __kPaperDetailModel_typeButtons:{//按钮
                _titleFrame = CGRectMake(__kPaperDetailModelFrame_left,y,maxWidth,__kPaperDetailModelFrame_btnHeight);
                _titleAttri = [NSStringUtils toHtmlWithText:_model.title];
                break;
            }
            default:
                break;
        }
        //输出行高
        _rowHeight = CGRectGetMaxY(_titleFrame) + __kPaperDetailModelFrame_bottom;
    }
}
@end
