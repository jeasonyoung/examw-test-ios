//
//  PaperDetailsTableViewCell.m
//  ExamwTestApp
//
//  Created by jeasonyoung on 15/5/26.
//  Copyright (c) 2015年 com.examw. All rights reserved.
//

#import "PaperDetailsTableViewCell.h"

#import "PaperDetailsModelCellFrame.h"
#import "EffectsUtils.h"
#import "UIColor+Hex.h"
//试卷明细Cell成员变量
@interface PaperDetailsTableViewCell (){
    UILabel *_lbDesc,*_lbSource,*_lbArea,*_lbType,*_lbTime,*_lbYear,*_lbTotal,*_lbScore;
}
@end
//试卷明细Cell实现
@implementation PaperDetailsTableViewCell

#pragma mark 重载初始化
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        //描述
        _lbDesc = [[UILabel alloc] init];
        _lbDesc.textAlignment = NSTextAlignmentLeft;
        _lbDesc.numberOfLines = 0;
        //试卷来源
        _lbSource = [[UILabel alloc] init];
        _lbSource.textAlignment = NSTextAlignmentLeft;
        _lbSource.numberOfLines = 0;
        //所属地区
        _lbArea = [[UILabel alloc] init];
        _lbArea.textAlignment = NSTextAlignmentLeft;
        _lbArea.numberOfLines = 0;
        //试卷类型
        _lbType = [[UILabel alloc] init];
        _lbType.textAlignment = NSTextAlignmentLeft;
        _lbType.numberOfLines = 0;
        //考试时长
        _lbTime = [[UILabel alloc] init];
        _lbTime.textAlignment = NSTextAlignmentLeft;
        _lbTime.numberOfLines = 0;
        //使用年份
        _lbYear = [[UILabel alloc] init];
        _lbYear.textAlignment = NSTextAlignmentCenter;
        _lbYear.numberOfLines = 0;
        //试题数
        _lbTotal = [[UILabel alloc] init];
        _lbTotal.textAlignment = NSTextAlignmentLeft;
        _lbTotal.numberOfLines = 0;
        //试卷总分
        _lbScore = [[UILabel alloc] init];
        _lbScore.textAlignment = NSTextAlignmentLeft;
        _lbScore.numberOfLines = 0;
        //添加到容器
        [self.contentView addSubview:_lbDesc];
        [self.contentView addSubview:_lbSource];
        [self.contentView addSubview:_lbArea];
        [self.contentView addSubview:_lbType];
        [self.contentView addSubview:_lbTime];
        [self.contentView addSubview:_lbYear];
        [self.contentView addSubview:_lbTotal];
        [self.contentView addSubview:_lbScore];
        
        [EffectsUtils addBoundsRadiusWithView:self BorderColor:[UIColor colorWithHex:0xBDB76B] BackgroundColor:nil];
    }
    return self;
}

#pragma mark 数据模型cell frame
-(void)loadModelCellFrame:(PaperDetailsModelCellFrame *)cellFrame{
    NSLog(@"加载试卷明细数据模型CellFrame...");
    if(!cellFrame)return;
    //描述
    _lbDesc.text = cellFrame.desc;
    _lbDesc.font = cellFrame.descFont;
    _lbDesc.frame = cellFrame.descFrame;
    //试卷来源
    _lbSource.text = cellFrame.source;
    _lbSource.font = cellFrame.sourceFont;
    _lbSource.frame = cellFrame.sourceFrame;
    //所属地区
    _lbArea.text = cellFrame.area;
    _lbArea.font = cellFrame.areaFont;
    _lbArea.frame = cellFrame.areaFrame;
    //试卷类型
    _lbType.text = cellFrame.type;
    _lbType.font = cellFrame.typeFont;
    _lbType.frame = cellFrame.typeFrame;
    //考试时长
    _lbTime.text = cellFrame.time;
    _lbTime.font = cellFrame.timeFont;
    _lbTime.frame = cellFrame.timeFrame;
    //使用年份
    _lbYear.text = cellFrame.year;
    _lbYear.font = cellFrame.yearFont;
    _lbYear.frame = cellFrame.yearFrame;
    //试题数
    _lbTotal.text = cellFrame.total;
    _lbTotal.font = cellFrame.totalFont;
    _lbTotal.frame = cellFrame.totalFrame;
    //试卷总分
    _lbScore.text = cellFrame.score;
    _lbScore.font = cellFrame.scoreFont;
    _lbScore.frame = cellFrame.scoreFrame;
}

@end
