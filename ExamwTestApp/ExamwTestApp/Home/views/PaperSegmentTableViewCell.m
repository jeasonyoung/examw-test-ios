//
//  PaperSegmentTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/1.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperSegmentTableViewCell.h"
#import "PaperSegmentModelCellFrame.h"
//试卷分段Cell成员变量
@interface PaperSegmentTableViewCell (){
    UILabel *_lbSubject,*_lbTotal;
}
@end
//试卷分段Cell实现
@implementation PaperSegmentTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //科目
        _lbSubject = [[UILabel alloc] init];
        _lbSubject.textAlignment = NSTextAlignmentLeft;
        _lbSubject.numberOfLines = 0;
        //统计
        _lbTotal = [[UILabel alloc] init];
        _lbTotal.textAlignment = NSTextAlignmentLeft;
        _lbTotal.numberOfLines = 0;
        //添加到容器
        [self.contentView addSubview:_lbSubject];
        [self.contentView addSubview:_lbTotal];
    }
    return self;
}

#pragma mark 加载数据模型Frame
-(void)loadModelCellFrame:(PaperSegmentModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    NSLog(@"加载数据模型Frame...");
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
