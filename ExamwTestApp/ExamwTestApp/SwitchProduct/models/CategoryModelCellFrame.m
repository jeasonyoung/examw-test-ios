//
//  CategoryModelFrame.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "CategoryModelCellFrame.h"
#import "ExamModel.h"

#define __kCategoryModelCellFrame_top 10//顶部间距
#define __kCategoryModelCellFrame_bottom 10//底部间距
#define __kCategoryModelCellFrame_left 10//左边间距
#define __kCategoryModelCellFrame_right 5//右边间距
#define __kCategoryModelCellFrame_maginMin 10//最小间距

//考试分类数据模型CellFrame成员变量
@interface CategoryModelCellFrame (){
    CGFloat _with;
    NSStringDrawingOptions _options;
}
@end
//考试分类数据模型CellFrame实现
@implementation CategoryModelCellFrame
#pragma mark 重载构造函数。
-(instancetype)init{
    if(self = [super init]){
        //屏幕宽度
        _with = CGRectGetWidth([[UIScreen mainScreen] bounds]);
        //
        _options = (NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading);
        
        //设置考试分类字体
        _categoryFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        //设置考试字体
        _examFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    }
    return self;
}
#pragma mark 设置数据模型
-(void)setModel:(CategoryModel *)model{
    //重置
    _categoryFrame = _exam1Frame = _exam2Frame = CGRectZero;
    
    if(!model)return;
    _categoryName = model.name;
    if(model.exams && model.exams.count > 0){
        _exam1Name = ((ExamModel *)[model.exams objectAtIndex:0]).name;
        if(model.exams.count > 1){
            _exam2Name = ((ExamModel *)[model.exams objectAtIndex:1]).name;
        }
    }
    CGFloat maxWith = _with - __kCategoryModelCellFrame_left - __kCategoryModelCellFrame_right;
    //
    CGSize categoryNameSize = CGSizeZero,exam1NameSize = CGSizeZero,exam2NameSize = CGSizeZero;
    //考试分类
    categoryNameSize = [_categoryName boundingRectWithSize:CGSizeMake(maxWith, CGFLOAT_MAX)
                                                   options:_options
                                                attributes:@{NSFontAttributeName:_categoryFont}
                                                   context:nil].size;
    //考试1
    if(_exam1Name && _exam1Name.length > 0){
        maxWith -= categoryNameSize.width - __kCategoryModelCellFrame_maginMin;
        exam1NameSize = [_exam1Name boundingRectWithSize:CGSizeMake(maxWith, CGFLOAT_MAX)
                                                 options:_options
                                              attributes:@{NSFontAttributeName:_examFont}
                                                 context:nil].size;
    }
    //考试2
    if(_exam2Name && _exam2Name.length > 0){
        maxWith -= exam1NameSize.width - __kCategoryModelCellFrame_maginMin;
        if (maxWith > 0) {
            exam2NameSize = [_exam2Name boundingRectWithSize:CGSizeMake(maxWith, exam1NameSize.height)
                                                     options:_options
                                                  attributes:@{NSFontAttributeName:_examFont}
                                                     context:nil].size;
        }
    }
    //
    CGFloat x = __kCategoryModelCellFrame_left, y = __kCategoryModelCellFrame_top;
    //考试分类Frame
    CGFloat maxHeight = 0;
    if(!CGSizeEqualToSize(categoryNameSize,CGSizeZero)){
        _categoryFrame = CGRectMake(x, y, categoryNameSize.width, categoryNameSize.height);
        maxHeight = CGRectGetMaxY(_categoryFrame);
    }
    //
    //考试1frame
    if(!CGSizeEqualToSize(exam1NameSize, CGSizeZero)){
        _exam1Frame = CGRectMake(CGRectGetMaxX(_categoryFrame) + __kCategoryModelCellFrame_maginMin,
                                 y + (categoryNameSize.height - exam1NameSize.height)/2,
                                 exam1NameSize.width, exam1NameSize.height);
        if(maxHeight < CGRectGetMaxY(_exam1Frame)){
            maxHeight = CGRectGetMaxY(_exam1Frame);
        }
    }
    //考试2frame
    if(!CGSizeEqualToSize(exam2NameSize, CGSizeZero)){
        _exam2Frame = CGRectMake(CGRectGetMaxX(_exam1Frame) + __kCategoryModelCellFrame_maginMin,
                                 CGRectGetMinY(_exam1Frame), exam2NameSize.width, exam2NameSize.height);
        if(maxHeight < CGRectGetMaxY(_exam2Frame)){
            maxHeight = CGRectGetMaxY(_exam2Frame);
        }
    }
    //高度
    _cellHeight = maxHeight + __kCategoryModelCellFrame_bottom;
}
@end
