//
//  LearnTableViewCell.m
//  ExamApp
//
//  Created by jeasonyoung on 15/3/30.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "LearnTableViewCell.h"
#import "UIColor+Hex.h"

#import "LearnRecordCellData.h"

#define __kLearnTableViewCell_img @"learn_record.png"

#define __kLearnTableViewCell_useTimesFontColor 0xFF0000//耗时的字体颜色

#define __kLearnTableViewCell_scoreFontColor 0xFF0000//得分颜色

#define __kLearnTableViewCell_lastTimeFontColor 0xDDA0DD//最后时间
//学习记录列表数据成员变量
@interface LearnTableViewCell (){
    UIImageView *_imgView;
    UILabel *_lbTitle,*_lbUseTimes,*_lbScore,*_lbLastTime;
}
@end
//学习记录列表数据实现
@implementation LearnTableViewCell
#pragma mark 重载初始化函数
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupInit];
    }
    return self;
}
//初始化
-(void)setupInit {
    //图片
    _imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:__kLearnTableViewCell_img]];
    
    //标题
    _lbTitle = [[UILabel alloc]init];
    _lbTitle.textAlignment = NSTextAlignmentLeft;
    _lbTitle.numberOfLines = 0;
    
    //耗时
    _lbUseTimes = [[UILabel alloc]init];
    _lbUseTimes.textAlignment = NSTextAlignmentLeft;
    _lbUseTimes.textColor = [UIColor colorWithHex:__kLearnTableViewCell_useTimesFontColor];
    
    //得分
    _lbScore = [[UILabel alloc]init];
    _lbScore.textAlignment = NSTextAlignmentLeft;
    _lbScore.textColor = [UIColor colorWithHex:__kLearnTableViewCell_scoreFontColor];
    
    //最后时间
    _lbLastTime = [[UILabel alloc]init];
    _lbLastTime.textAlignment = NSTextAlignmentLeft;
    _lbLastTime.textColor = [UIColor colorWithHex:__kLearnTableViewCell_lastTimeFontColor];

    //添加到容器
    [self.contentView addSubview:_imgView];
    [self.contentView addSubview:_lbTitle];
    [self.contentView addSubview:_lbUseTimes];
    [self.contentView addSubview:_lbScore];
    [self.contentView addSubview:_lbLastTime];
}
#pragma mark 重载选中方法
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark 加载数据
-(void)loadData:(LearnRecordCellData *)data{
    if(!data)return;
    
    //图片
    _imgView.frame = data.imgFrame;
    //标题
    _lbTitle.frame = data.titleFrame;
    _lbTitle.font = data.titleFont;
    _lbTitle.text = data.title;
    //耗时
    _lbUseTimes.frame = data.useTimeFrame;
    _lbUseTimes.font = data.useTimeFont;
    _lbUseTimes.text = data.useTime;
    //得分
    _lbScore.frame = data.scoreFrame;
    _lbScore.font = data.scoreFont;
    _lbScore.text = data.score;
    //最后时间
    _lbLastTime.frame = data.lastTimeFrame;
    _lbLastTime.font = data.lastTimeFont;
    _lbLastTime.text = data.lastTime;
    
}
@end
