//
//  MySubjectModelTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/3.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "MySubjectModelTableViewCell.h"
#import "MySubjectModelCellFrame.h"
#import "UIColor+Hex.h"

#define __kMySubjectModelTableViewCell_totalFontColor 0xBEBEBE//
//我的列表数据模型Cell成员变量
@interface MySubjectModelTableViewCell (){
    UIImageView *_iconView;
    UILabel *_lbSubject,*_lbTotal;
}
@end
//我的列表数据模型Cell实现
@implementation MySubjectModelTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //icon
        _iconView = [[UIImageView alloc] init];
        //科目
        _lbSubject = [[UILabel alloc] init];
        _lbSubject.textAlignment = NSTextAlignmentLeft;
        _lbSubject.numberOfLines = 0;
        //统计
        _lbTotal = [[UILabel alloc] init];
        _lbTotal.textAlignment = NSTextAlignmentLeft;
        _lbTotal.numberOfLines = 0;
        _lbTotal.textColor = [UIColor colorWithHex:__kMySubjectModelTableViewCell_totalFontColor];
        //添加到容器
        [self.contentView addSubview:_iconView];
        [self.contentView addSubview:_lbSubject];
        [self.contentView addSubview:_lbTotal];
    }
    return self;
}

#pragma mark 加载数据模型Cell Frame
-(void)loadModelCellFrame:(MySubjectModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    //icon
    if(cellFrame.icon){
        _iconView.image = cellFrame.icon;
        _iconView.frame = cellFrame.iconFrame;
    }
    //科目
    _lbSubject.font = cellFrame.subjectFont;
    _lbSubject.frame = cellFrame.subjectFrame;
    _lbSubject.text = cellFrame.subject;
    //统计
    _lbTotal.font = cellFrame.totalFont;
    _lbTotal.frame = cellFrame.totalFrame;
    _lbTotal.text = cellFrame.total;
}
@end
