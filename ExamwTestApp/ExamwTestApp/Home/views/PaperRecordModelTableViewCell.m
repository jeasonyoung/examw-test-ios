//
//  PaperRecordModelTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/6/4.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperRecordModelTableViewCell.h"
#import "PaperRecordModelCellFrame.h"
//试卷做题记录数据模型Cell成员变量
@interface PaperRecordModelTableViewCell (){
    UIImageView *_imgView;
    UILabel *_lbPaperName,*_lbStatus, *_lbScore, *_lbRights,*_lbUseTimes, *_lbTime;
}
@end
//试卷做题记录数据模型Cell实现
@implementation PaperRecordModelTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //图片
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        //_imgView.backgroundColor = [UIColor lightGrayColor];
        //试卷名称
        _lbPaperName = [[UILabel alloc] init];
        _lbPaperName.textAlignment = NSTextAlignmentLeft;
        _lbPaperName.numberOfLines = 0;
        //状态
        _lbStatus = [[UILabel alloc] init];
        _lbStatus.textAlignment = NSTextAlignmentLeft;
        _lbStatus.numberOfLines = 0;
        //得分
        _lbScore = [[UILabel alloc] init];
        _lbScore.textAlignment = NSTextAlignmentLeft;
        _lbScore.numberOfLines = 0;
        //正确
        _lbRights = [[UILabel alloc] init];
        _lbRights.textAlignment = NSTextAlignmentLeft;
        _lbRights.numberOfLines = 0;
        //用时
        _lbUseTimes = [[UILabel alloc] init];
        _lbUseTimes.textAlignment = NSTextAlignmentLeft;
        _lbUseTimes.numberOfLines = 0;
        //时间
        _lbTime = [[UILabel alloc] init];
        _lbTime.textAlignment = NSTextAlignmentLeft;
        _lbTime.numberOfLines = 0;
        //
        //添加到容器
        [self.contentView addSubview:_imgView];
        [self.contentView addSubview:_lbPaperName];
        [self.contentView addSubview:_lbStatus];
        [self.contentView addSubview:_lbScore];
        [self.contentView addSubview:_lbRights];
        [self.contentView addSubview:_lbUseTimes];
        [self.contentView addSubview:_lbTime];
    }
    return self;
}

#pragma mark 加载数据模型Frame
-(void)loadModelCellFrame:(PaperRecordModelCellFrame *)cellFrame{
    if(!cellFrame)return;
    //图片
    if(cellFrame.img){
        _imgView.image = cellFrame.img;
        _imgView.frame = cellFrame.imgFrame;
    }
    //试卷名称
    _lbPaperName.font = cellFrame.paperNameFont;
    _lbPaperName.frame = cellFrame.paperNameFrame;
    _lbPaperName.text = cellFrame.paperName;
    //状态
    _lbStatus.font = cellFrame.statusFont;
    _lbStatus.frame = cellFrame.statusFrame;
    _lbStatus.text = cellFrame.status;
    //得分
    _lbScore.font = cellFrame.scoreFont;
    _lbScore.frame = cellFrame.scoreFrame;
    _lbScore.text = cellFrame.score;
    //正确
    _lbRights.font = cellFrame.rightsFont;
    _lbRights.frame = cellFrame.rightsFrame;
    _lbRights.text = cellFrame.rights;
    //用时
    _lbUseTimes.font = cellFrame.useTimesFont;
    _lbUseTimes.frame = cellFrame.useTimesFrame;
    _lbUseTimes.text = cellFrame.useTimes;
    //时间
    _lbTime.font = cellFrame.timeFont;
    _lbTime.frame = cellFrame.timeFrame;
    _lbTime.text = cellFrame.time;
}
@end
