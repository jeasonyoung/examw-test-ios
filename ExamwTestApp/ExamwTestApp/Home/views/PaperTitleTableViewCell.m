//
//  PaperTitleTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperTitleTableViewCell.h"
#import "PaperTitleModelCellFrame.h"

//试卷标题Cell成员变量
@interface PaperTitleTableViewCell (){
    UILabel *_lbTitle,*_lbSubject;
}
@end
//试卷标题Cell实现
@implementation PaperTitleTableViewCell

#pragma mark 重载初始化
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
        //_lbSubject.textColor = [UIColor grayColor];
        //添加容器
        [self.contentView addSubview:_lbTitle];
        [self.contentView addSubview:_lbSubject];
    }
    return self;
}


#pragma mark 加载数据模型Frame
-(void)loadModelCellFrame:(PaperTitleModelCellFrame *)cellFrame{
    NSLog(@"加载试卷标题数据模型Frame...");
    if(!cellFrame)return;
    //试卷标题
    _lbTitle.text = cellFrame.title;
    _lbTitle.font = cellFrame.titleFont;
    _lbTitle.frame = cellFrame.titleFrame;
    //所属科目
    _lbSubject.text = cellFrame.subject;
    _lbSubject.font = cellFrame.subjectFont;
    _lbSubject.frame = cellFrame.subjectFrame;
}

@end
