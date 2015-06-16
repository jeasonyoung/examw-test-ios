//
//  SubjectTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/16.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "SubjectTableViewCell.h"
#import "SubjectModelCellFrame.h"

#import "AppConstants.h"

#import "TTTAttributedLabel.h"

//科目Cell成员变量
@interface SubjectTableViewCell (){
    TTTAttributedLabel *_lbSubject,*_lbTotals;
}
@end
//科目Cell实现
@implementation SubjectTableViewCell

#pragma mark 初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //科目名称
        _lbSubject = [[TTTAttributedLabel alloc] init];
        _lbSubject.textAlignment = NSTextAlignmentLeft;
        _lbSubject.numberOfLines = 0;
        _lbSubject.lineSpacing = [AppConstants globalLineSpacing];
        _lbSubject.minimumLineHeight = [AppConstants globalLineHeight];
        //试卷统计
        _lbTotals = [[TTTAttributedLabel alloc] init];
        _lbTotals.textAlignment = NSTextAlignmentLeft;
        _lbTotals.numberOfLines = 0;
        _lbTotals.textColor = [UIColor grayColor];
        _lbTotals.lineSpacing = [AppConstants globalLineSpacing];
        _lbTotals.minimumLineHeight = [AppConstants globalLineHeight];
        //添加到容器
        [self.contentView addSubview:_lbSubject];
        [self.contentView addSubview:_lbTotals];
    }
    return self;
}

#pragma mark 加载数据模型Frame
-(void)loadModelCellFrame:(SubjectModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    //科目名称
    _lbSubject.font = cellFrame.nameFont;
    _lbSubject.frame = cellFrame.nameFrame;
    _lbSubject.text = cellFrame.name;
    //试卷统计
    _lbTotals.font = cellFrame.totalFont;
    _lbTotals.frame = cellFrame.totalFrame;
    _lbTotals.text = cellFrame.total;
}
@end
