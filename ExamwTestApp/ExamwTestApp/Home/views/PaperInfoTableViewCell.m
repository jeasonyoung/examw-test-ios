//
//  PaperInfoTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/25.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperInfoTableViewCell.h"
#import "PaperInfoModelCellFrame.h"

//试卷信息Cell成员变量
@interface PaperInfoTableViewCell (){
    UILabel *_lbTitle,*_lbSubject,*_lbTotal,*_lbCreateTime;
}
@end

//试卷信息Cell实现
@implementation PaperInfoTableViewCell

#pragma mark 重置构造函数
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //试卷标题
        _lbTitle = [[UILabel alloc] init];
        _lbTitle.textAlignment = NSTextAlignmentLeft;
        _lbTitle.numberOfLines = 0;
        //所属科目
        _lbSubject = [[UILabel alloc] init];
        _lbSubject.textAlignment = NSTextAlignmentLeft;
        _lbSubject.numberOfLines = 0;
        //试卷数
        _lbTotal = [[UILabel alloc] init];
        _lbTotal.textAlignment = NSTextAlignmentLeft;
        _lbTotal.numberOfLines = 0;
        //创建时间
        _lbCreateTime = [[UILabel alloc] init];
        _lbCreateTime.textAlignment = NSTextAlignmentLeft;
        _lbCreateTime.numberOfLines = 0;
        _lbCreateTime.textColor = [UIColor grayColor];
        //添加到容器
        [self.contentView addSubview:_lbTitle];
        [self.contentView addSubview:_lbSubject];
        [self.contentView addSubview:_lbTotal];
        [self.contentView addSubview:_lbCreateTime];
    }
    return self;
}

#pragma mark 加载数据模型Frame
-(void)loadModelCellFrame:(PaperInfoModelCellFrame *)cellFrame{
    NSLog(@"加载试卷信息数据模型Frame...");
    if(!cellFrame)return;
    //试卷标题
    _lbTitle.text = cellFrame.title;
    _lbTitle.font = cellFrame.titleFont;
    _lbTitle.frame = cellFrame.titleFrame;
    //所属科目
    _lbSubject.text = cellFrame.subject;
    _lbSubject.font = cellFrame.subjectFont;
    _lbSubject.frame = cellFrame.subjectFrame;
    //试卷数
    _lbTotal.text = cellFrame.total;
    _lbTotal.font = cellFrame.totalFont;
    _lbTotal.frame = cellFrame.totalFrame;
    //创建时间
    _lbCreateTime.text = cellFrame.createTime;
    _lbCreateTime.font = cellFrame.createTimeFont;
    _lbCreateTime.frame = cellFrame.createTimeFrame;
}

#pragma mark 重置选中
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
