//
//  CategoryTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/19.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "CategoryTableViewCell.h"

//考试分类TableViewCell成员变量
@interface CategoryTableViewCell(){
    UILabel *_lbCategory,*_lbExam1,*_lbExam2;
}
@end
//考试分类TableViewCell实现
@implementation CategoryTableViewCell
#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //考试分类
        _lbCategory = [[UILabel alloc]init];
        _lbCategory.textAlignment = NSTextAlignmentLeft;
        _lbCategory.numberOfLines = 0;
        //考试1
        _lbExam1 = [[UILabel alloc]init];
        _lbExam1.textAlignment = NSTextAlignmentLeft;
        //考试1
        _lbExam2 = [[UILabel alloc]init];
        _lbExam2.textAlignment = NSTextAlignmentLeft;
        //
        [self.contentView addSubview:_lbCategory];
        [self.contentView addSubview:_lbExam1];
        [self.contentView addSubview:_lbExam2];
    }
    return self;
}

#pragma mark 重载选中
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark 加载数据
-(void)loadModelCellFrame:(CategoryModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    //
    _lbCategory.font = cellFrame.categoryFont;
    _lbCategory.text = cellFrame.categoryName;
    _lbCategory.frame = cellFrame.categoryFrame;
    //
    _lbExam1.font = cellFrame.examFont;
    _lbExam1.text = cellFrame.exam1Name;
    _lbExam1.frame = cellFrame.exam1Frame;
    //
    _lbExam2.font = cellFrame.examFont;
    _lbExam2.text = cellFrame.exam2Name;
    _lbExam2.frame = cellFrame.exam2Frame;
    
}

@end
